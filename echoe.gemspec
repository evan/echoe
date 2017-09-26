# -*- encoding: utf-8 -*-
# stub: echoe 4.7.0 ruby lib

Gem::Specification.new do |s|
  s.name = "echoe".freeze
  s.version = "4.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.8.4".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Evan Weaver".freeze]
  s.date = "2017-09-26"
  s.description = "A Rubygems packaging tool that provides Rake tasks for documentation, extension compiling, testing, and deployment.".freeze
  s.email = "".freeze
  s.extra_rdoc_files = ["CHANGELOG".freeze, "LICENSE".freeze, "README.rdoc".freeze, "lib/echoe.rb".freeze, "lib/echoe/extensions.rb".freeze, "lib/echoe/platform.rb".freeze, "lib/echoe/rubygems.rb".freeze]
  s.files = ["CHANGELOG".freeze, "LICENSE".freeze, "MIT-LICENSE".freeze, "Manifest".freeze, "README.rdoc".freeze, "Rakefile".freeze, "echoe.gemspec".freeze, "echoe.pem".freeze, "lib/echoe.rb".freeze, "lib/echoe/extensions.rb".freeze, "lib/echoe/platform.rb".freeze, "lib/echoe/rubygems.rb".freeze, "vendor/rake/MIT-LICENSE".freeze, "vendor/rake/lib/rake/contrib/compositepublisher.rb".freeze, "vendor/rake/lib/rake/contrib/ftptools.rb".freeze, "vendor/rake/lib/rake/contrib/publisher.rb".freeze, "vendor/rake/lib/rake/contrib/rubyforgepublisher.rb".freeze, "vendor/rake/lib/rake/contrib/sshpublisher.rb".freeze, "vendor/rake/lib/rake/contrib/sys.rb".freeze]
  s.homepage = "http://fauna.github.com/fauna/echoe/".freeze
  s.licenses = ["Academic Free License (AFL) v. 3.0".freeze]
  s.rdoc_options = ["--line-numbers".freeze, "--title".freeze, "Echoe".freeze, "--main".freeze, "README.rdoc".freeze]
  s.rubyforge_project = "fauna".freeze
  s.rubygems_version = "2.6.11".freeze
  s.summary = "A Rubygems packaging tool that provides Rake tasks for documentation, extension compiling, testing, and deployment.".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rubyforge>.freeze, [">= 2.0.4"])
      s.add_runtime_dependency(%q<allison>.freeze, [">= 2.0.3"])
      s.add_runtime_dependency(%q<rdoc>.freeze, [">= 2.5.11"])
      s.add_runtime_dependency(%q<rake>.freeze, [">= 0.9.2"])
    else
      s.add_dependency(%q<rubyforge>.freeze, [">= 2.0.4"])
      s.add_dependency(%q<allison>.freeze, [">= 2.0.3"])
      s.add_dependency(%q<rdoc>.freeze, [">= 2.5.11"])
      s.add_dependency(%q<rake>.freeze, [">= 0.9.2"])
    end
  else
    s.add_dependency(%q<rubyforge>.freeze, [">= 2.0.4"])
    s.add_dependency(%q<allison>.freeze, [">= 2.0.3"])
    s.add_dependency(%q<rdoc>.freeze, [">= 2.5.11"])
    s.add_dependency(%q<rake>.freeze, [">= 0.9.2"])
  end
end
