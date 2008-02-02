require "pstore"
require "monitor"

# == TimedCache
# 
# TimedCache implements a cache in which you can place objects
# and specify a timeout value.
# 
# If you attempt to retrieve the object within the specified timeout
# period, the object will be returned. If the timeout period has elapsed,
# the TimedCache will return nil.
# 
# e.g.:
#   cache = TimedCache.new
#   cache.put :my_object_key, "Expensive data", 10 # => "Expensive data"
#   
#   cache.get :my_object_key # => "Expensive data"
#   cache[:my_object_key]    # => "Expensive data"
# 
# ... 10 seconds later:
#   cache.get :my_object_key # => nil
# 
# === Default timeout
# 
# When creating a new TimedCache, a default timeout value can be set. This value
# will be used for each object added to the cache, unless a different timeout value
# is specifically set for that object.
# 
# e.g.:
# 
#   cache = TimedCache.new(:default_timeout => 120)
#   cache.default_timeout # => 120
# 
# === File-based cache
# 
# By default, TimedCache will use an in-memory store. A file-based store (using the 
# PStore library) can also be used.
# 
# e.g.:
# 
#   TimedCache.new(:type => :file, :filename => "my_cache.db")
# 
# The file-based cache makes it possible to easily share a cache between several ruby 
# processes. However when using the cache in this way, you will probably want to update the 
# cache by passing a block to the TimedCache#get method (see below for details).
# 
# Note that objects that cannot be marshalled (e.g. a Proc) can't be stored using the file-based cache.
class TimedCache
  VERSION = "0.2"
  
  attr_reader :default_timeout
  
  # Create a new TimedCache. Available options are:
  # <tt>type</tt>:: <tt>:memory</tt> or <tt>:file</tt> (defaults to <tt>:memory</tt>).
  # <tt>default_timeout</tt>:: Timeout to use if none is specified when adding an object to the cache.
  # <tt>filename</tt>:: Must be specified when using the <tt>:file</tt> type store.
  # 
  # e.g.:
  #   TimedCache.new(:type => :file, :filename => "cache.db")
  def initialize(opts = {})
    opts[:type] ||= :memory
    @default_timeout = opts[:default_timeout] || 60
    @store = new_store(opts)
    @store.extend(MonitorMixin)
  end
  
  # Add an object to the cache. e.g.:
  #   cache.put(:session_id, 12345)
  # 
  # The third parameter is an optional timeout value. If not specified, the 
  # <tt>:default_timeout</tt> for this TimedCache will be used instead.
  def put(key, value, timeout = @default_timeout)
    @store.synchronize do
      @store.put(key, value, timeout) unless value.nil?
    end
  end
  
  # Retrieve the object which the given +key+. If the object has expired or
  # is not present, +nil+ is returned.
  # 
  # Optionally, a block can be given. The result of evaluating the block will
  # be substituted as the cache value, if the cache has expired. This is particularly
  # useful when using a file-based cache from multiple ruby processes, as it
  # will prevent your application from making multiple simultaneous attempts to 
  # re-populate the cache.
  # 
  # e.g.:
  # 
  #   cache.get("slow_database_query") do
  #     MyDatabase.query("SELECT * FROM bigtable...")
  #   end
  # 
  # The block syntax can also be used with the in-memory cache.
  def get(key, &block)
    @store.synchronize do
      @store.get(key, &block)
    end
  end
  
  # Add to the cache using a hash-like syntax. e.g.:
  #   cache[:name] = "Nick"
  # 
  # Note that adding to the cache this way does not allow you to specify timeout values
  # on a per-object basis.
  def []=(key, value)
    put(key, value)
  end
  
  # Fetch objects using the hash syntax. e.g.:
  #   cache[:name] # => "Nick"
  def [](key)
    get(key)
  end
  
  protected
  
  def new_store(options) #:nodoc:
    self.class.const_get(options[:type].to_s.capitalize + "Store").new(self, options)
  end
  
  class Store #:nodoc:
    def initialize(timed_cache, options)
      @timed_cache = timed_cache
      @options     = options
    end
    
    protected
    
    def generic_get(key, timeout, callback, fetch_key = lambda {|k| @cache[key]})
      if object_store = fetch_key.call(key)
        if object_store.expired?
          if callback
            run_callback_and_add_to_cache(key, object_store, callback, timeout)
          else
            # Free up memory:
            @cache[key] = nil
          end
        else
          object_store.object
        end
      elsif callback
        run_callback_and_add_to_cache(key, object_store, callback, timeout)
      end
    end
    
    def run_callback_and_add_to_cache(key, object_store, callback, timeout)
      object_store.no_expiry! if object_store
      
      begin
        result = callback.call
      rescue
        object_store.reset_expiry! if object_store
        raise
      end
      
      @timed_cache.put(key, result, timeout)
      result
    end
  end
  
  class MemoryStore < Store #:nodoc:
    def initialize(*args)
      super(*args)
      @cache = Hash.new
    end
    
    def put(key, value, timeout)
      @cache[key] = ObjectContainer.new(value, timeout)
      # Return just the given value, so that references to the
      # ObjectStore instance can't be held outside this TimedCache:
      value
    end
    
    def get(key, timeout = @timed_cache.default_timeout, &block)
      generic_get(key, timeout, block)
    end
  end
  
  class FileStore < Store #:nodoc:
    def initialize(*args)
      super(*args)
      filename = @options[:filename]
      unless filename
        raise ArgumentError, ":filename option must be specified for :file type store."
      end
      @cache = PStore.new(filename)
    end
    
    def put(key, value, timeout)
      @cache.transaction { @cache[key] = ObjectContainer.new(value, timeout) }
      
      # Return just the given value, so that references to the
      # ObjectStore instance can't be held outside this TimedCache:
      value
    end
    
    def get(key, timeout = @timed_cache.default_timeout, &block)
      if block
        generic_get(key, timeout, block, lambda {|k| @cache.transaction { @cache[key] } })
      else
        @cache.transaction { generic_get(key, timeout, block) }
      end
    end
  end
  
  class ObjectContainer #:nodoc:
    attr_accessor :object
    
    def initialize(object, timeout)
      @created_at = Time.now.utc
      @timeout    = timeout
      @object     = object
      @frozen     = false
    end
    
    def expired?
      if @frozen: false
      else
        (Time.now.utc - @timeout) > @created_at
      end
    end
    
    def no_expiry!
      @frozen = true
    end
    
    def reset_expiry!
      @frozen = false
    end
  end
end
