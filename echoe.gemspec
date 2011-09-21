# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{echoe}
  s.version = "4.6.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.8.4") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Evan Weaver}]
  s.cert_chain = [%q{/Users/eweaver/p/configuration/gem_certificates/evan_weaver-original-public_cert.pem}]
  s.date = %q{2011-09-21}
  s.description = %q{A Rubygems packaging tool that provides Rake tasks for documentation, extension compiling, testing, and deployment.}
  s.email = %q{}
  s.extra_rdoc_files = [%q{CHANGELOG}, %q{LICENSE}, %q{README}, %q{lib/echoe.rb}, %q{lib/echoe/extensions.rb}, %q{lib/echoe/platform.rb}, %q{lib/echoe/rubygems.rb}]
  s.files = [%q{CHANGELOG}, %q{LICENSE}, %q{MIT-LICENSE}, %q{Manifest}, %q{README}, %q{Rakefile}, %q{echoe.gemspec}, %q{lib/echoe.rb}, %q{lib/echoe/extensions.rb}, %q{lib/echoe/platform.rb}, %q{lib/echoe/rubygems.rb}, %q{vendor/rake/MIT-LICENSE}, %q{vendor/rake/lib/rake/contrib/compositepublisher.rb}, %q{vendor/rake/lib/rake/contrib/ftptools.rb}, %q{vendor/rake/lib/rake/contrib/publisher.rb}, %q{vendor/rake/lib/rake/contrib/rubyforgepublisher.rb}, %q{vendor/rake/lib/rake/contrib/sshpublisher.rb}, %q{vendor/rake/lib/rake/contrib/sys.rb}]
  s.homepage = %q{http://fauna.github.com/fauna/echoe/}
  s.rdoc_options = [%q{--line-numbers}, %q{--inline-source}, %q{--title}, %q{Echoe}, %q{--main}, %q{README}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{fauna}
  s.rubygems_version = %q{1.8.6}
  s.signing_key = %q{/Users/eweaver/p/configuration/gem_certificates/evan_weaver-original-private_key.pem}
  s.summary = %q{A Rubygems packaging tool that provides Rake tasks for documentation, extension compiling, testing, and deployment.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<gemcutter>, [">= 0.7.0"])
      s.add_runtime_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_runtime_dependency(%q<allison>, [">= 2.0.3"])
      s.add_runtime_dependency(%q<rdoc>, [">= 3.6.1"])
      s.add_runtime_dependency(%q<rake>, [">= 0.9.2"])
    else
      s.add_dependency(%q<gemcutter>, [">= 0.7.0"])
      s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_dependency(%q<allison>, [">= 2.0.3"])
      s.add_dependency(%q<rdoc>, [">= 3.6.1"])
      s.add_dependency(%q<rake>, [">= 0.9.2"])
    end
  else
    s.add_dependency(%q<gemcutter>, [">= 0.7.0"])
    s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
    s.add_dependency(%q<allison>, [">= 2.0.3"])
    s.add_dependency(%q<rdoc>, [">= 3.6.1"])
    s.add_dependency(%q<rake>, [">= 0.9.2"])
  end
end
