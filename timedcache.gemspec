require 'timedcache/version'

Gem::Specification.new do |s|
  s.name = "timedcache"
  s.version = TimedCache::VERSION
  s.summary = %q{TimedCache implements a cache in which you can place objects and specify a timeout value.}
  s.description = %q{TimedCache implements a cache in which you can place objects and specify a timeout value.  If you attempt to retrieve the object within the specified timeout, the object will be returned. If the timeout period has elapsed, the TimedCache will return nil.}
  s.files = Dir['**/*']
  s.authors = ["Nicholas Dainty"]
  s.email = "nick@npad.co.uk"
  s.homepage = "http://timedcache.rubyforge.org/"
  s.has_rdoc = true
  s.rdoc_options = ["--charset=UTF-8", "--line-numbers", "--inline-source"]
  s.required_ruby_version = '>= 1.8.6'
end
