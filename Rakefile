require File.join(File.dirname(__FILE__), "lib/timedcache")

require "rubygems"
require "rake/rdoctask"
require "rake/gempackagetask"

Rake::RDocTask.new { |rdoc|
  rdoc.rdoc_dir = "doc"
  rdoc.title    = "TimedCache Documentation"
  rdoc.rdoc_files.include("MIT_LICENSE", "lib/timedcache.rb")
  rdoc.options << "--line-numbers" << "--inline-source"
  rdoc.main = "TimedCache"
}

gemspec = Gem::Specification.new do |s|
  s.name         = "timedcache"
  s.version      = TimedCache::Version
  s.author       = "Nicholas Dainty"
  s.email        = "nick@npad.co.uk"
  s.homepage     = "http://timedcache.rubyforge.org"
  s.platform     = Gem::Platform::RUBY
  s.summary      = "A very simple time-based object cache."
  s.description  = <<EOF
TimedCache implements a cache in which you can place objects
and specify a timeout value.

If you attempt to retrieve the object within the specified timeout
period, the object will be returned. If the timeout period has elapsed,
the TimedCache will return nil.
EOF
  s.files             = FileList["{doc,lib,specs}/*"].to_a
  s.require_paths     = "lib"
  s.autorequire       = "timedcache"
  s.has_rdoc          = true
  s.extra_rdoc_files  = ["MIT_LICENSE"]
  s.rubyforge_project = "timedcache"
  
  s.rdoc_options.concat(["--main",  "TimedCache", "--line-numbers", "--inline-source"])
end

Rake::GemPackageTask.new(gemspec) do |pkg|
  pkg.need_tar = true
  pkg.need_zip = true
end
