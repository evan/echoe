($:.unshift File.expand_path(File.join( File.dirname(__FILE__), 'lib' ))).uniq!
require 'echoe'

Echoe.new('echoe') do |p|
  p.project = 'fauna'
  p.author = 'Evan Weaver'
  p.summary = 'A Rubygems packaging tool that provides Rake tasks for documentation, extension compiling, testing, and deployment.'
  p.runtime_dependencies = ['rubyforge >=2.0.4', 'allison >=2.0.3', 'rdoc >=2.5.11', 'rake >=0.9.2']
  p.development_dependencies = []
  p.certificate_chain = "echoe.pem"
  p.require_signed
  p.retain_gemspec = true
  p.licenses = ["Academic Free License (AFL) v. 3.0"]
  p.rubygems_version = ">=1.8.4"
end
