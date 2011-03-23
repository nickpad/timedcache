require File.expand_path('../lib/timedcache', File.dirname(__FILE__))

# This script will almost certainly raise an exception if the cache is not
# thread safe.

db = File.join(File.dirname(__FILE__), "thread_test.db")

cache = TimedCache.new(:type => :file, :filename => File.join(db))

threads = []

10.times do
  threads << Thread.new do
    100.times {
      cache.put("thread-safe?", "let's find out")
      cache.get("thread-safe?")
    }
  end
end


threads.each { |t| t.join }

File.delete(db)
