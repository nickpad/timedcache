Gem::Specification.new do |s|
  s.name = %q{timedcache}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nicholas Dainty"]
  s.date = %q{2009-03-29}
  s.description = %q{TimedCache implements a cache in which you can place objects and specify a timeout value.  If you attempt to retrieve the object within the specified timeout, the object will be returned. If the timeout period has elapsed, the TimedCache will return nil.}
  s.email = %q{}
  s.files = Dir['**/*']
  s.homepage = %q{http://timedcache.rubyforge.org/}
  s.rdoc_options = ["--charset=UTF-8", "--line-numbers", "--inline-source"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{TimedCache implements a cache in which you can place objects and specify a timeout value.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3
  end
end
