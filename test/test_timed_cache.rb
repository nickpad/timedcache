require 'test/unit'
require 'timedcache'

class TimedCacheTest < Test::Unit::TestCase
  def setup
    @filename     = File.join(File.dirname(__FILE__), "specs.db")
    @memory_cache = TimedCache.new
    @file_cache   = TimedCache.new(:type => :file, :filename => @filename)
    @caches       = [@memory_cache, @file_cache]
  end

  def teardown
    File.delete(@filename) if File.exist?(@filename)
  end

  def test_can_add_an_object_to_the_cache_specifying_a_timeout_value
    @caches.each do |cache|
      assert_equal("This needs caching", cache.put(:myobject, "This needs caching", 10))
    end
  end

  def test_can_add_an_object_to_the_cache_specifying_a_timeout_value_using_the_set_method
    @caches.each do |cache|
      assert_equal("This needs caching", cache.set(:myobject, "This needs caching", 10))
    end
  end

  def test_can_remove_objects_from_the_cache
    @caches.each do |cache|
      cache.put(:myobject, "This needs caching", 10)
      assert_equal("This needs caching", cache.get(:myobject))
      cache.del(:myobject)
      assert_nil(cache.get(:myobject))
    end
  end

  def test_cache_should_hold_seperate_values_for_each_key
    @caches.each do |cache|
      assert_equal("This needs caching", cache.put(:myobject, "This needs caching", 10))
      assert_equal("...and this too", cache.put(:my_other_object, "...and this too", 10))
      assert_equal("This needs caching", cache.get(:myobject))
      assert_equal("...and this too", cache.get(:my_other_object))
    end
  end

  def test_string_and_symbol_keys_are_not_treated_as_equivalent
    @caches.each do |cache|
      cache[:symbolkey]  = "Referenced by symbol"
      cache["stringkey"] = "Referenced by string"

      assert_equal("Referenced by symbol", cache[:symbolkey])
      assert_nil(cache["symbolkey"])

      assert_equal("Referenced by string", cache["stringkey"])
      assert_nil(cache[:stringkey])
    end
  end

  def test_after_the_specified_timeout_value_has_elapsed_nil_should_be_returned
    @caches.each do |cache|
      assert_equal("This needs caching", cache.put(:myobject, "This needs caching", 0))
      assert_nil(cache.get(:myobject))
    end
  end

  def test_if_no_object_matching_the_given_key_is_found_nil_should_be_returned
    @caches.each do |cache|
      assert_nil(cache.get(:my_nonexistant_object))
    end
  end

  def test_should_be_able_to_use_an_array_as_a_cache_key
    @caches.each do |cache|
      assert_equal("Array", cache.put([123,234], "Array"))
      assert_equal("Array", cache.get([123,234]))
    end
  end

  def test_passing_a_block_to_the_get_method_should_substitute_result_of_block_as_value_for_given_key
    @caches.each do |cache|
      cache.put("block_test", 1984, 0)
      assert_equal(2001, cache.get("block_test") { 2001 })
      assert_equal(2001, cache.get("block_test"))
    end
  end

  def test_passing_block_to_get_should_add_result_of_callback_when_there_is_no_existing_value
    @caches.each do |cache|
      assert_equal(nil, cache.get("new_key_with_block"))
      assert_equal("Nicholas", cache.get("new_key_with_block") { "Nicholas" })
    end
  end

  def test_is_able_to_specify_default_timeout_when_creating_an_instance
    cache = TimedCache.new(:default_timeout => 20)
    assert_equal(20, cache.default_timeout)
  end

  def test_if_no_default_timeout_is_set_60_seconds_should_be_used
    cache = TimedCache.new
    assert_equal(60, cache.default_timeout)
  end

  def test_timeout_specified_when_putting_a_new_object_into_the_cache_should_override_default_timeout
    cache = TimedCache.new(:default_timeout => 20)
    assert_equal(20, cache.default_timeout)
    cache.put("alternative_timeout", "2 minutes", 120)

    timeout = cache.instance_variable_get(:@store).
      instance_variable_get(:@cache)["alternative_timeout"].
      instance_variable_get(:@timeout)

    assert_equal(120, timeout)
  end
end
