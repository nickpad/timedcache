require File.join(File.dirname(__FILE__), "../lib/timedcache")

$filename = File.join(File.dirname(__FILE__), "specs.db")

describe "Adding and retrieving objects from the cache" do
  before(:each) do
    @memory_cache = TimedCache.new
    @file_cache   = TimedCache.new(:type => :file, :filename => $filename)
    @caches       = [@memory_cache, @file_cache]
  end
  
  after do
    File.delete($filename)
  end
  
  it "Can add an object to the cache, specifying a timeout value" do
    @caches.each do |cache|
      cache.put(:myobject, "This needs caching", 10).should == "This needs caching"
    end
  end
    
  it "Cache should hold seperate values for each key" do
    @caches.each do |cache|    
      cache.put(:myobject, "This needs caching", 10).should == "This needs caching"
      cache.put(:my_other_object, "...and this too", 10).should == "...and this too"
      cache.get(:myobject).should == "This needs caching"
      cache.get(:my_other_object).should == "...and this too"
    end
  end
  
  it "String and symbol keys are not treated as equivalent" do
    @caches.each do |cache|
      cache[:symbolkey]  = "Referenced by symbol"
      cache["stringkey"] = "Referenced by string"
      
      cache[:symbolkey].should == "Referenced by symbol"
      cache["symbolkey"].should == nil
      
      cache["stringkey"].should == "Referenced by string"
      cache[:stringkey].should == nil
    end
  end
  
  it "After the specified timeout value has elapsed, nil should be returned" do
    @caches.each do |cache|    
      cache.put(:myobject, "This needs caching", 0).should == "This needs caching"
      cache.get(:myobject).should == nil
    end
  end
  
  it "If no object matching the given key is found, nil should be returned" do
    @caches.each do |cache|
      cache.get(:my_nonexistant_object).should == nil
    end
  end
  
  it "Should be able to use an array as a cache key" do
    @caches.each do |cache|
      cache.put([123,234], "Array").should == "Array"
      cache.get([123,234]).should == "Array"
    end
  end
  
  it "Passing a block to the TimedCache#get method should substitute the " +
     "result of the block as the value for the given key" do
    @caches.each do |cache|
      cache.put("block_test", 1984, 0)
      cache.get("block_test") { 2001 }.should == 2001
      cache.get("block_test").should == 2001
    end
  end
  
  it "Passing a block to TimedCache#get should add the result of the callback " + 
     "when there is no existing value for the key given" do
    @caches.each do |cache|
      cache.get("new_key_with_block").should == nil
      cache.get("new_key_with_block") { "Nicholas" }.should == "Nicholas"
    end
  end
end

describe "Specifying a default timeout" do
  it "Should be able to it a default timeout when creating a TimedCache" do
    cache = TimedCache.new(:default_timeout => 20)
    cache.should be_kind_of(TimedCache)
    cache.default_timeout.should == 20
  end
  
  it "If no default timeout is set, 60 seconds should be used" do
    cache = TimedCache.new
    cache.should be_kind_of(TimedCache)
    cache.default_timeout.should == 60
  end
  
  it "Timeout specified when putting a new object into the cache should override default timeout" do
    cache = TimedCache.new(:default_timeout => 20)
    cache.default_timeout.should == 20
    cache.put("alternative_timeout", "2 minutes", 120)
    cache.instance_variable_get(:@store).instance_variable_get(:@cache)["alternative_timeout"].
    instance_variable_get(:@timeout).should == 120
  end
end
