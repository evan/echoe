
require 'lib/echoe'

Echoe.new("echoe", `cat CHANGELOG`[/^([\d\.]+)\. /, 1]) do |p|
  p.name = "echoe"
  p.rubyforge_name = "fauna"
  p.author = "Evan Weaver"
  p.summary = "Echoe is a simple packaging tool for working with rubygems."
  p.description = "Echoe is a simple packaging tool for working with rubygems. It
generates all the usual tasks for projects including rdoc generation, testing, packaging, and deployment."
  p.changes = `cat CHANGELOG`[/^([\d\.]+\. .*)/, 1]

  p.url = "http://blog.evanweaver.com/pages/code#echoe"
  p.docs_host = "blog.evanweaver.com:~/www/snax/public/files/doc/"

  p.extra_deps = [['rake'], ['rubyforge', '>= 0.4.0']]

end

