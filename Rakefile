$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'

# ============================================================================

# If you're using this file as a template to set up a new gem, this constant
# is the only thing you should need to change in the Rakefile:
GEM_NAME = 'timedcache'

# ============================================================================

Rake::TestTask.new do |t|
  t.libs << 'test'
end

# ============================================================================
# = Gem package and release stuff.
# ============================================================================

spec = eval(File.read(File.join(File.dirname(__FILE__), "#{GEM_NAME}.gemspec")))

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

# ============================================================================

task :default => [:test]
