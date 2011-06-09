($:.unshift File.expand_path(File.join( File.dirname(__FILE__), 'lib' ))).uniq!
require 'echoe'

Echoe.new('echoe') do |p|
  p.project = 'fauna'
  p.author = 'Evan Weaver'
  p.summary = 'A Rubygems packaging tool that provides Rake tasks for documentation, extension compiling, testing, and deployment.'
  p.runtime_dependencies = ['gemcutter >=0.7.0', 'rubyforge >=2.0.4', 'allison >=2.0.3', 'rdoc >=3.6.1', 'rake >=0.9.2']
  p.development_dependencies = []
  p.retain_gemspec = true
  p.rubygems_version = ">=1.8.4"
end

