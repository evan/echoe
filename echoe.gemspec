# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "echoe"
  s.version = "4.6.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.8.4") if s.respond_to? :required_rubygems_version=
  s.authors = ["Evan Weaver"]
  s.cert_chain = ["/Users/eweaver/p/configuration/gem_certificates/evan_weaver-original-public_cert.pem"]
  s.date = "2012-02-19"
  s.description = "A Rubygems packaging tool that provides Rake tasks for documentation, extension compiling, testing, and deployment."
  s.email = ""
  s.extra_rdoc_files = ["CHANGELOG", "LICENSE", "README.rdoc", "lib/echoe.rb", "lib/echoe/extensions.rb", "lib/echoe/platform.rb", "lib/echoe/rubygems.rb"]
  s.files = ["CHANGELOG", "LICENSE", "MIT-LICENSE", "Manifest", "README.rdoc", "Rakefile", "echoe.gemspec", "lib/echoe.rb", "lib/echoe/extensions.rb", "lib/echoe/platform.rb", "lib/echoe/rubygems.rb", "vendor/rake/MIT-LICENSE", "vendor/rake/lib/rake/contrib/compositepublisher.rb", "vendor/rake/lib/rake/contrib/ftptools.rb", "vendor/rake/lib/rake/contrib/publisher.rb", "vendor/rake/lib/rake/contrib/rubyforgepublisher.rb", "vendor/rake/lib/rake/contrib/sshpublisher.rb", "vendor/rake/lib/rake/contrib/sys.rb"]
  s.homepage = "http://fauna.github.com/fauna/echoe/"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Echoe", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "fauna"
  s.rubygems_version = "1.8.15"
  s.signing_key = "/Users/eweaver/p/configuration/gem_certificates/evan_weaver-original-private_key.pem"
  s.summary = "A Rubygems packaging tool that provides Rake tasks for documentation, extension compiling, testing, and deployment."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<gemcutter>, [">= 0.7.0"])
      s.add_runtime_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_runtime_dependency(%q<allison>, [">= 2.0.3"])
      s.add_runtime_dependency(%q<rdoc>, [">= 2.5.11"])
      s.add_runtime_dependency(%q<rake>, [">= 0.9.2"])
    else
      s.add_dependency(%q<gemcutter>, [">= 0.7.0"])
      s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_dependency(%q<allison>, [">= 2.0.3"])
      s.add_dependency(%q<rdoc>, [">= 2.5.11"])
      s.add_dependency(%q<rake>, [">= 0.9.2"])
    end
  else
    s.add_dependency(%q<gemcutter>, [">= 0.7.0"])
    s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
    s.add_dependency(%q<allison>, [">= 2.0.3"])
    s.add_dependency(%q<rdoc>, [">= 2.5.11"])
    s.add_dependency(%q<rake>, [">= 0.9.2"])
  end
end
