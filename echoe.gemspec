# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{echoe}
  s.version = "3.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Evan Weaver"]
  s.cert_chain = ["/Users/eweaver/p/configuration/gem_certificates/evan_weaver-original-public_cert.pem"]
  s.date = %q{2009-02-19}
  s.description = %q{A Rubygems packaging tool that provides Rake tasks for documentation, extension compiling, testing, and deployment.}
  s.email = %q{}
  s.extra_rdoc_files = ["CHANGELOG", "lib/echoe/client.rb", "lib/echoe/extensions.rb", "lib/echoe/platform.rb", "lib/echoe/rubygems.rb", "lib/echoe.rb", "LICENSE", "README", "TODO"]
  s.files = ["CHANGELOG", "echoe.gemspec", "lib/echoe/client.rb", "lib/echoe/extensions.rb", "lib/echoe/platform.rb", "lib/echoe/rubygems.rb", "lib/echoe.rb", "LICENSE", "Manifest", "MIT-LICENSE", "Rakefile", "README", "TODO", "vendor/rake/bin/rake", "vendor/rake/CHANGES", "vendor/rake/doc/example/a.c", "vendor/rake/doc/example/b.c", "vendor/rake/doc/example/main.c", "vendor/rake/doc/example/Rakefile1", "vendor/rake/doc/example/Rakefile2", "vendor/rake/doc/glossary.rdoc", "vendor/rake/doc/jamis.rb", "vendor/rake/doc/proto_rake.rdoc", "vendor/rake/doc/rake.1.gz", "vendor/rake/doc/rakefile.rdoc", "vendor/rake/doc/rational.rdoc", "vendor/rake/doc/release_notes/rake-0.4.14.rdoc", "vendor/rake/doc/release_notes/rake-0.4.15.rdoc", "vendor/rake/doc/release_notes/rake-0.5.0.rdoc", "vendor/rake/doc/release_notes/rake-0.5.3.rdoc", "vendor/rake/doc/release_notes/rake-0.5.4.rdoc", "vendor/rake/doc/release_notes/rake-0.6.0.rdoc", "vendor/rake/doc/release_notes/rake-0.7.0.rdoc", "vendor/rake/doc/release_notes/rake-0.7.1.rdoc", "vendor/rake/doc/release_notes/rake-0.7.2.rdoc", "vendor/rake/doc/release_notes/rake-0.7.3.rdoc", "vendor/rake/doc/release_notes/rake-0.8.0.rdoc", "vendor/rake/doc/release_notes/rake-0.8.2.rdoc", "vendor/rake/doc/release_notes/rake-0.8.3.rdoc", "vendor/rake/install.rb", "vendor/rake/lib/rake/classic_namespace.rb", "vendor/rake/lib/rake/clean.rb", "vendor/rake/lib/rake/contrib/compositepublisher.rb", "vendor/rake/lib/rake/contrib/ftptools.rb", "vendor/rake/lib/rake/contrib/publisher.rb", "vendor/rake/lib/rake/contrib/rubyforgepublisher.rb", "vendor/rake/lib/rake/contrib/sshpublisher.rb", "vendor/rake/lib/rake/contrib/sys.rb", "vendor/rake/lib/rake/gempackagetask.rb", "vendor/rake/lib/rake/loaders/makefile.rb", "vendor/rake/lib/rake/packagetask.rb", "vendor/rake/lib/rake/rake_test_loader.rb", "vendor/rake/lib/rake/rdoctask.rb", "vendor/rake/lib/rake/ruby182_test_unit_fix.rb", "vendor/rake/lib/rake/runtest.rb", "vendor/rake/lib/rake/tasklib.rb", "vendor/rake/lib/rake/testtask.rb", "vendor/rake/lib/rake/win32.rb", "vendor/rake/lib/rake.rb", "vendor/rake/MIT-LICENSE", "vendor/rake/Rakefile", "vendor/rake/README", "vendor/rake/test/capture_stdout.rb", "vendor/rake/test/check_expansion.rb", "vendor/rake/test/contrib/test_sys.rb", "vendor/rake/test/data/chains/Rakefile", "vendor/rake/test/data/default/Rakefile", "vendor/rake/test/data/dryrun/Rakefile", "vendor/rake/test/data/file_creation_task/Rakefile", "vendor/rake/test/data/imports/deps.mf", "vendor/rake/test/data/imports/Rakefile", "vendor/rake/test/data/multidesc/Rakefile", "vendor/rake/test/data/namespace/Rakefile", "vendor/rake/test/data/rakelib/test1.rb", "vendor/rake/test/data/rbext/rakefile.rb", "vendor/rake/test/data/sample.mf", "vendor/rake/test/data/statusreturn/Rakefile", "vendor/rake/test/data/unittest/Rakefile", "vendor/rake/test/filecreation.rb", "vendor/rake/test/functional.rb", "vendor/rake/test/in_environment.rb", "vendor/rake/test/rake_test_setup.rb", "vendor/rake/test/reqfile.rb", "vendor/rake/test/reqfile2.rb", "vendor/rake/test/session_functional.rb", "vendor/rake/test/shellcommand.rb", "vendor/rake/test/test_application.rb", "vendor/rake/test/test_clean.rb", "vendor/rake/test/test_definitions.rb", "vendor/rake/test/test_earlytime.rb", "vendor/rake/test/test_extension.rb", "vendor/rake/test/test_file_creation_task.rb", "vendor/rake/test/test_file_task.rb", "vendor/rake/test/test_filelist.rb", "vendor/rake/test/test_fileutils.rb", "vendor/rake/test/test_ftp.rb", "vendor/rake/test/test_invocation_chain.rb", "vendor/rake/test/test_makefile_loader.rb", "vendor/rake/test/test_multitask.rb", "vendor/rake/test/test_namespace.rb", "vendor/rake/test/test_package_task.rb", "vendor/rake/test/test_pathmap.rb", "vendor/rake/test/test_rake.rb", "vendor/rake/test/test_require.rb", "vendor/rake/test/test_rules.rb", "vendor/rake/test/test_task_arguments.rb", "vendor/rake/test/test_task_manager.rb", "vendor/rake/test/test_tasklib.rb", "vendor/rake/test/test_tasks.rb", "vendor/rake/test/test_test_task.rb", "vendor/rake/test/test_top_level_functions.rb", "vendor/rake/test/test_win32.rb", "vendor/rake/TODO"]
  s.has_rdoc = true
  s.homepage = %q{http://blog.evanweaver.com/files/doc/fauna/echoe/}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Echoe", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{fauna}
  s.rubygems_version = %q{1.3.1}
  s.signing_key = %q{/Users/eweaver/p/configuration/gem_certificates/evan_weaver-original-private_key.pem}
  s.summary = %q{A Rubygems packaging tool that provides Rake tasks for documentation, extension compiling, testing, and deployment.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rubyforge>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<highline>, [">= 0"])
    else
      s.add_dependency(%q<rubyforge>, [">= 1.0.0"])
      s.add_dependency(%q<highline>, [">= 0"])
    end
  else
    s.add_dependency(%q<rubyforge>, [">= 1.0.0"])
    s.add_dependency(%q<highline>, [">= 0"])
  end
end
