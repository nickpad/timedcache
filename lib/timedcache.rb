require "pstore"

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
# Note that objects that cannot be marshalled (e.g. a Proc) can't be stored using the file-based cache.
class TimedCache
  Version = "0.1.1"
  
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
  end
  
  # Add an object to the cache. e.g.:
  #   cache.put(:session_id, 12345)
  # 
  # The third parameter is an optional timeout value. If not specified, the 
  # <tt>:default_timeout</tt> for this TimedCache will be used instead.
  def put(key, value, timeout = @default_timeout)
    @store.put(key, value, timeout)
  end
  
  # Retrieve the object which the given +key+. If the object has expired or
  # is not present, +nil+ is returned.
  def get(key)
    @store.get(key)
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
    self.class.const_get(options[:type].to_s.capitalize + "Store").new(options)
  end
  
  class Store #:nodoc:
    def initialize(options)
      @options = options
    end
  end
  
  class MemoryStore < Store #:nodoc:
    def initialize(options)
      super
      @cache = Hash.new
    end
    
    def put(key, value, timeout)
      @cache[key] = ObjectContainer.new(value, timeout)
      # Return just the given value, so that references to the
      # ObjectStore instance can't be held outside this TimedCache:
      value
    end
    
    def get(key)
      if object_store = @cache[key]
        if object_store.expired?
          # Free up memory:
          @cache[key] = nil
        else
          object_store.object
        end
      end
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
    
    def put(key, value, timeout = nil)
      @cache.transaction do
        @cache[key] = ObjectContainer.new(value, timeout)
      end
      
      # Return just the given value, so that references to the
      # ObjectStore instance can't be held outside this TimedCache:
      value
    end
    
    def get(key)
      @cache.transaction do
        if object_store = @cache[key]
          if object_store.expired?
            # Free up memory:
            @cache[key] = nil
          else
            object_store.object
          end
        end
      end
    end
  end
  
  class ObjectContainer #:nodoc:
    attr_reader :object
    
    def initialize(object, timeout)
      @created_at = Time.now.utc
      @timeout    = timeout
      @object     = object
    end
    
    def expired?
      (Time.now.utc - @timeout) > @created_at
    end
  end
end
