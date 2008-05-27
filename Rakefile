
require 'lib/echoe'

Echoe.new('echoe') do |p|
  p.project = 'fauna'
  p.author = 'Evan Weaver'
  p.summary = 'A Rubygems packaging tool that provides Rake tasks for documentation, extension compiling, testing, and deployment.'
  p.url = 'http://blog.evanweaver.com/files/doc/fauna/echoe/'
  p.docs_host = 'blog.evanweaver.com:~/www/bax/public/files/doc/'
  p.dependencies = ['rake', 'rubyforge =0.4.5', 'highline']
  p.require_signed = true
  p.rubygems_version = '>= 0.9.4.5'

  # Echoe is self-dependent
  p.include_gemspec = false
  p.include_rakefile = true    
end

