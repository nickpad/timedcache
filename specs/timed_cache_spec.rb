require File.join(File.dirname(__FILE__), "../lib/timedcache")

$filename = File.join(File.dirname(__FILE__), "specs.db")

context "Adding and retrieving objects from the cache" do
  setup do
    @memory_cache = TimedCache.new
    @file_cache   = TimedCache.new(:type => :file, :filename => $filename)
    @caches = [@memory_cache, @file_cache]
  end
  
  teardown do
    File.delete($filename)
  end
  
  specify "Can add an object to the cache, specifying a timeout value" do
    @caches.each do |cache|
      cache.put(:myobject, "This needs caching", 10).should_equal "This needs caching"
    end
  end
    
  specify "Cache should hold seperate values for each key" do
    @caches.each do |cache|    
      cache.put(:myobject, "This needs caching", 10).should_equal "This needs caching"
      cache.put(:my_other_object, "...and this too", 10).should_equal "...and this too"
      cache.get(:myobject).should_equal "This needs caching"
      cache.get(:my_other_object).should_equal "...and this too"
    end
  end
  
  specify "After the specified timeout value has elapsed, nil should be returned" do
    @caches.each do |cache|    
      cache.put(:myobject, "This needs caching", 0).should_equal "This needs caching"
      cache.get(:myobject).should_equal nil
    end
  end
  
  specify "If no object matching the given key is found, nil should be returned" do
    @caches.each do |cache|
      cache.get(:my_nonexistant_object).should_equal nil
    end
  end
  
  specify "Should be able to use an array as a cache key" do
    @caches.each do |cache|
      cache.put([123,234], "Array").should_equal "Array"
      cache.get([123,234]).should_equal "Array"
    end
  end
end

context "Specifying a default timeout" do
  specify "Should be able to specify a default timeout when creating a TimedCache" do
    cache = TimedCache.new(:default_timeout => 20)
    cache.should_be_kind_of TimedCache
    cache.default_timeout.should_equal 20
  end
  
  specify "If no default timeout is set, 60 seconds should be used" do
    cache = TimedCache.new
    cache.should_be_kind_of TimedCache
    cache.default_timeout.should_equal 60
  end
  
  specify "Timeout specified when putting a new object into the cache should override default timeout" do
  end
end
