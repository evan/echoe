
$HERE = File.dirname(__FILE__)

require 'rake'
require 'rake/clean'
require "#{$HERE}/../vendor/rake/lib/rake/contrib/compositepublisher"
require "#{$HERE}/../vendor/rake/lib/rake/contrib/sshpublisher"
require 'rubygems/package_task'
require 'rdoc/task'
require 'rake/testtask'
begin
require 'spec/rake/spectask'
rescue LoadError
end
require 'rbconfig'
require 'open-uri'
require 'tmpdir'

require "#{$HERE}/echoe/extensions"

require 'rubygems'
require 'rubyforge'

Echoe.silence { require 'rubygems/specification' }

require "#{$HERE}/echoe/rubygems"
begin
  gem 'gemcutter'
  require 'rubygems_plugin'
rescue Gem::LoadError
end

begin; require 'rcov/rcovtask'; rescue LoadError; end
begin; require 'load_multi_rails_rake_tasks'; rescue LoadError; end

=begin rdoc

Echoe includes some optional accessors for more advanced gem configuration.

For example, a simple <tt>Rakefile</tt> might look like this:

  require 'echoe'

  Echoe.new("uncapitalizer") do |p|
    p.author = "Evan Weaver"
    p.summary = "A library that uncapitalizes strings."
    p.runtime_dependencies = ["string_tools >=1.4.0"]
  end

See below for the full list.

== Signing gems

Echoe supports signing gems. First, create yourself a public and private key:
  gem cert --build you@yourmail.com

Move them somewhere secret, and add the following environment variables in your <tt>.bash_profile</tt> or similar:
  export GEM_PRIVATE_KEY='/secret/path/to/gem-private_key.pem'
  export GEM_CERTIFICATE_CHAIN='/secret/path/to/gem-public_cert.pem'

Make sure your environment is up-to-date:
  source ~/.bash_profile

Upload your <tt>public_cert.pem</tt> file to your website or Rubyforge project, and tell your users to add that certificate to their system via:
  gem cert --add /path/to/public_cert.pem

Finally, package and release your project as normal. Now users can install your gem via:
  sudo gem install gemname -P HighSecurity

Note that you can also set the key and certificate locations in the Rakefile itself. Finally, you can add <tt>p.require_signed = true</tt> to your <tt>Rakefile</tt> so that you don't accidentally release an unsigned gem if your key is missing.

== Metadependencies

Echoe does not force packages to depend on Echoe itself. Instead, it generates a <tt>gemspec</tt> from your <tt>Rakefile</tt> and includes that. Downstream repackagers can use the <tt>gemspec</tt> as-is to build new versions of your gem even without Echoe.

== Cross-packaging

Echoe supports platform Rake targets to allow you to cross-package your gems. Just write the spec assuming <tt>RUBY_PLATFORM</tt> will be what you need it to be for each architecture, and then invoke Rake with the platform name when you're cross-packaging.

For example, on JRuby, <tt>rake package</tt> will build a generic <tt>-ruby</tt> type gem. But if you want to include a Java-specific extension, you can do one of two things. You can package from within JRuby by checking if <tt>RUBY_PLATFORM =~ /java/</tt> and setting <tt>p.platform = jruby</tt>, or you can run <tt>rake java package</tt>, which will set <tt>RUBY_PLATFORM</tt> and <tt>p.platform</tt> for you.

This way you can run <tt>rake java package</tt>, <tt>rake aix install</tt>, or whatever task you need and Echoe will behave just like you're packaging from within the target platform.

== Test environment setup and teardown

For some applications, you may need to setup and teardown environment state for the entire test suite. This is especially common for integration tests that may need to spawn an external daemon. To support this, you can add a file <tt>tests/setup.rb</tt> and it will be silently executed before the entire suite runs. Add a similar file <tt>tests/teardown.rb</tt> in your app to be executed at the end of the entire run.

Note; these files will only get executed if you run the tests via <tt>rake</tt>. Also, you can set the environment variable <tt>VERBOSE=1</tt> to not hide the setup/teardown output.

== Accessor options

Descriptive options:

* <tt>author</tt> - Your name.
* <tt>email</tt> - Your email address.
* <tt>description</tt> - A more detailed description of the library.
* <tt>summary</tt> - A shorter description of the library.
* <tt>url</tt> - A url for the library. Defaults to generated RDoc on GitHub pages for the project.f
* <tt>install_message</tt> - A message to display after the gem is installed.

Versioning options:

* <tt>version</tt> - A string for the version number. Parsed from CHANGELOG otherwise.
* <tt>changes</tt> - A string describing the most recent changes. Parsed from CHANGELOG otherwise.

Common packaging options:

* <tt>runtime_dependencies</tt> - An array of runtime dependencies for this gem. For example, <tt>['mongrel', 'activesupport >= 2.0.2']</tt>.
* <tt>development_dependencies</tt> - An array of development dependencies for this gem. For example, <tt>['rake >=0.7.1']</tt>.
* <tt>extension_pattern</tt> - A filename array, glob array, or regex for extension files that need to be run at install time. Defaults to <tt>"ext/**/extconf.rb"</tt>.

Testing options:

* <tt>clean_pattern</tt> - A filename array, glob array, or regex for files that should be removed when <tt>rake clean</tt> is run.
* <tt>test_pattern</tt> - A filename array, glob array, or regex for test runners. Overridden by <tt>"test/test_all.rb"</tt>, if it exists.

* <tt>spec_pattern</tt> - A filename array, glob array, or regex for test runners.
* <tt>rcov_options</tt> - Any extra flags to pass to RCov when coverage reports are run.

Uncommon packaging options:
* <tt>platform</tt> - What platform this gem is for.
* <tt>manifest_name</tt> - The name of the manifest file. Defaults to <tt>Manifest</tt>.
* <tt>need_gem</tt> - Whether to generate a gem package. Defaults to <tt>true</tt>.
* <tt>need_tar_gz</tt> - Whether to generate a <tt>.tar.gz</tt> package. Defaults to <tt>true</tt>.
* <tt>need_tgz</tt> - Whether to generate a <tt>.tgz</tt> package. Defaults to <tt>false</tt>.
* <tt>need_zip</tt> - Whether to generate a <tt>.zip</tt> package. Defaults to <tt>false</tt>.
* <tt>include_rakefile</tt> - Include the Rakefile directly within the package. Defaults to <tt>true</tt>.
* <tt>include_gemspec</tt> - Include the generated gemspec file within the package. Defaults to <tt>true</tt>.
* <tt>ruby_version</tt> - Version string for which Ruby to require (for example, <tt>'>= 1.8.4'</tt>.
* <tt>eval</tt> - Accepts a proc to be evaluated in the context of the Gem::Specification object. This allows you to set more unusual gemspec options.
* <tt>ignore_pattern</tt> - A filename array, glob array, or regex for pathnames that should be ignored when building the manifest.
* <tt>require_paths</tt> - Non-standard requirement paths to add to the gem definition.
* <tt>executable_pattern</tt> - A filename array, glob array, or regex for files that should be installed as wrapped executables.

Security options:

* <tt>private_key</tt> - The path to your gem private key. Defaults to ENV['GEM_PRIVATE_KEY'], if available. This accessor is not published in the resulting gemspec.
* <tt>certificate_chain</tt> - An array representing your certificate authorization chain. If no one else has signed your certificate, just set it to your own cert. Defaults to ENV['GEM_CERTIFICATE_CHAIN'], if available. This accessor is not published in the resulting gemspec.
* <tt>require_signed</tt> - Force Echoe to refuse to package your gem if it's not properly signed. Default false.

Publishing options:

* <tt>project</tt> - The name of the Rubyforge project. Defaults to the name of the gem.
* <tt>docs_host</tt> - A host and filesystem path to publish the documentation to. Defaults to GitHub pages for the project. SSH upload to an accessible static file host also works.

Documentation options:

* <tt>rdoc_pattern</tt> - A filename array, glob array, or regex for filenames that should be passed to RDoc.
* <tt>rdoc_template</tt> - A path to an RDoc template. Defaults to the generic template.

=end

class Echoe
  include Rake::DSL

  # user-configurable
  attr_accessor :author, :changes, :clean_pattern, :description, :email, :runtime_dependencies, :development_dependencies, :need_tgz, :need_tar_gz, :need_gem, :need_zip, :rdoc_pattern, :project, :summary, :test_pattern, :spec_pattern, :url, :version, :docs_host, :rdoc_template, :manifest_name, :install_message, :extension_pattern, :private_key, :certificate_chain, :require_signed, :ruby_version, :platform, :ignore_pattern, :executable_pattern, :require_paths, :changelog, :rcov_options, :gemspec_format

  # best left alone
  attr_accessor :name, :lib_files, :test_files, :bin_files, :spec, :rdoc_options, :include_gemspec, :include_rakefile, :gemspec_name, :retain_gemspec, :rakefile_name, :eval, :files, :changelog_patterns, :rubygems_version, :use_sudo, :gem_bin

  # legacy
  attr_accessor :extra_deps, :rdoc_files, :extensions, :dependencies

  def initialize(name, _version = nil)
    # Defaults

    self.name = name
    self.project = name.downcase
    self.changelog = "CHANGELOG"
    self.author = ""
    self.email = ""
    self.clean_pattern = ["pkg", "doc", 'build/*', '**/coverage', '**/*.o', '**/*.so', '**/*.a', '**/*.log', "{ext,lib}/*.{bundle,so,obj,pdb,lib,def,exp}", "ext/Makefile", "{ext,lib}/**/*.{bundle,so,obj,pdb,lib,def,exp}", "ext/**/Makefile", "pkg", "*.gem", ".config"]
    self.test_pattern = File.exist?("test/test_all.rb") ? "test/test_all.rb" : ['test/**/test_*.rb', 'test/**/*_test.rb']
    self.spec_pattern = "spec/**/*_spec.rb"

    self.ignore_pattern = /^(pkg|doc)|(\.svn|CVS|\.bzr|\.DS|\.git)$/

    self.changelog_patterns = {
        :version => [
            /^\s*v([\d\w\.]+)(\.|\s|$)/,
            /\s*\*\s*([\d\w\.]+)\s*\*\s*$/
          ],
        :changes => [
          /^\s*v([\d\.]+\. .*)/,
          /\*\s*[\d\.]+\s*\*\s*(.*)\*\s*[\d\.]+\s*\*$/m
        ]
      }

    self.description = ""
    self.summary = ""
    self.install_message = nil
    self.executable_pattern = /^bin\//
    self.require_paths = nil
    self.use_sudo = !(Platform.windows? or ENV['GEM_HOME'].to_s.include?(ENV['USER'].to_s))
    self.gem_bin = "gem#{Platform.suffix}"
    self.rcov_options = []
    self.rdoc_pattern = /^(lib|bin|tasks|ext)|^README|^CHANGELOG|^TODO|^LICENSE|^COPYING$/

    self.gemspec_format = :ruby

    title = (name.downcase == name ? name.capitalize : name)
    self.rdoc_options = ['--line-numbers', '--inline-source', '--title', title]

    readme = Dir['*'].detect { |filename| filename =~ /^readme/i }
    self.rdoc_options += ['--main', readme] if readme

    self.runtime_dependencies = []
    self.development_dependencies = [] # These appear to not work at all
    self.manifest_name = "Manifest"
    self.extension_pattern = ["ext/**/extconf.rb", "ext/extconf.rb"]
    self.private_key = ENV['GEM_PRIVATE_KEY']
    self.require_signed = false
    self.certificate_chain = ENV['GEM_CERTIFICATE_CHAIN'].to_s.split(/\,\s*/).compact

    self.need_gem = true
    self.need_tar_gz = true
    self.need_tgz = false
    self.need_zip = false
    self.platform = $platform

    self.include_rakefile = true
    self.include_gemspec = true
    self.gemspec_name = "#{name}.gemspec"
    self.retain_gemspec = false
    self.rakefile_name = "Rakefile"
    self.rubygems_version = ">= 1.2"

    yield self if block_given?

    self.docs_host ||= "git@github.com:#{self.project}/#{self.project}.github.com"
    if self.docs_host =~ /git@github.com/
      self.url ||= "http://#{self.project}.github.com/#{self.project}/#{(self.name + '/') if project != name}"
    end

    # legacy compatibility
    self.runtime_dependencies = dependencies if dependencies and runtime_dependencies.empty?
    self.runtime_dependencies = extra_deps if extra_deps and runtime_dependencies.empty?
    self.rdoc_pattern = rdoc_files if rdoc_files
    self.extension_pattern = extensions if extensions

    # read manifest
    begin
      self.files = File.readlines(manifest_name).map { |x| x.strip } +
        [(gemspec_name if include_gemspec)] +
        [(rakefile_name if include_rakefile)]
      self.files = files.compact.uniq
    rescue Errno::ENOENT
      unless ARGV.include? "manifest"
        puts "Missing manifest. You can build one with 'rake manifest'."
        exit 1
      else
        self.files = []
      end
    end

    # snag version and changeset
    self.version ||= _version
    unless version
      if File.exist? changelog
        parsed = Array(changelog_patterns[:version]).map do |pattern|
          open(changelog) do |log|
            log.read[pattern, 1]
          end
        end.compact.first
        raise "Could not parse version from #{changelog}" unless parsed
        self.version = parsed.chomp(".").strip
      else
        raise "No #{changelog} found, and no version supplied in Rakefile."
      end
    end

    unless self.changes
      self.changes = if File.exist? changelog
        Array(changelog_patterns[:changes]).map do |pattern|
          open(changelog) do |log|
            log.read[pattern, 1]
          end
        end.compact.first or ""
      else
        ""
      end
    end

    # set some post-defaults
    self.certificate_chain = Array(certificate_chain).map {|file| File.expand_path(file)}
    self.private_key = File.expand_path(private_key) if private_key
    self.description = summary if description.empty?
    self.summary = description if summary.empty?
    self.clean_pattern = apply_pattern(clean_pattern)
    self.extension_pattern = apply_pattern(extension_pattern, files)

    self.ignore_pattern = apply_pattern(ignore_pattern)
    honor_gitignore! if File.exist?(".git")

    self.rdoc_pattern = apply_pattern(rdoc_pattern, files) - [manifest_name]
    self.executable_pattern = apply_pattern(executable_pattern, files)
    self.test_pattern = apply_pattern(test_pattern)
    self.spec_pattern = apply_pattern(spec_pattern)

    define_tasks
  end

private
  def honor_gitignore!
    self.ignore_pattern += \
      Dir["**/.gitignore"].inject([]) do |pattern,gitignore|
        pattern.concat \
          File.readlines(gitignore).
            map    { |line| line.strip }.
            reject { |line| "" == line }.
            map    { |glob|
              d = File.dirname(gitignore)
              d == "." ? glob : File.join(d, glob)
            }
      end.flatten.uniq
  end

  def apply_pattern(pattern, files = nil)
    files ||= Dir['**/**']
    case pattern
      when String, Array
        files & (Array(pattern).map do |p|
          Dir.glob(p)
        end.flatten)
      when Regexp
        files.select do |file|
          file =~ pattern
        end
      when FileList
        pattern.each do |ignorefile|
          ignorefiles = File.open(ignorefile).to_a.map(&:chomp)
          files = files.select do |file|
            ignorefiles.map { |i| File.fnmatch(i, file) }.include?(true)
          end
        end
        files
      else
        []
    end
  end

  def define_tasks

    ### Packaging and Installing

    self.spec = Gem::Specification.new do |s|
      s.name = name
      s.version = version
      # s.specification_version = 3
      s.summary = summary
      s.author = Array(author).join(", ")
      s.email = email
      s.homepage = url
      s.rubyforge_project = project if project
      s.post_install_message = install_message if install_message
      s.description = description
      s.required_ruby_version = ruby_version
      s.required_rubygems_version = rubygems_version if rubygems_version
      s.platform = platform
      s.rdoc_options = rdoc_options
      s.extra_rdoc_files = rdoc_pattern

      if private_key and File.exist? private_key
        s.signing_key = private_key
        s.cert_chain = certificate_chain
      end

      runtime_dependencies.each do |dep|
        dep = dep.split(" ") if dep.is_a? String
        s.add_runtime_dependency(*dep)
      end

      development_dependencies.each do |dep|
        dep = dep.split(" ") if dep.is_a? String
        s.add_development_dependency(*dep)
      end

      s.files = files

      s.bindir = if executable_pattern.any?
        executable_pattern[0].split("/")[0]
      else
        "bin"
      end

      s.executables = executable_pattern.map do |file|
        file[(s.bindir.length + 1)..-1]
      end

      dirs = Dir['{lib,ext}']
      s.extensions = extension_pattern if extension_pattern.any?
      if require_paths
        s.require_paths = require_paths
      else
        s.require_paths = dirs unless dirs.empty?
      end

      if File.exist? "test/test_all.rb"
        s.test_file = "test/test_all.rb"
      else
        s.test_files = test_pattern
      end

      if eval
        s.instance_eval &eval
      end

    end

    self.lib_files = spec.files.grep(/^lib/)
    self.bin_files = spec.files.grep(/^bin/)
    self.test_files = spec.files.grep(/^test/)

    Gem::PackageTask.new(spec) do |pkg|
      pkg.need_tar = @need_tgz
      pkg.need_tar_gz = @need_tar_gz
      pkg.need_zip = @need_zip
    end

    desc "Display Echoe's knowledge of your system"
    task :details do
      (self.instance_variables.sort - ['@spec']).each do |var|
        puts "#{var}: #{instance_variable_get(var).inspect}"
      end
    end

    desc "Builds the .gemspec"
    task :build_gemspec do
      # Construct the gemspec file, if needed.
      if include_gemspec
        File.open(gemspec_name, 'w') do |f|
          case gemspec_format
          when :yaml
            spec.to_yaml.split("\n").each do |line|
              # Don't publish any information about the private key or certificate chain
              f.puts line unless line =~ /signing_key|cert_chain|\.pem/
            end
          when :ruby
            f.puts spec.to_ruby
          else
            raise "Unknown gemspec format #{gemspec_format.inspect}. Supported formats: :ruby and :yaml"
          end
        end
      end
      puts "Gemspec generated"
    end

    # Chain it to the gemspec task prerequisite
    task gemspec_name.to_sym => [:build_gemspec]

    desc "Generates manifest & gemspec in one go"
    task :build => [:manifest, :build_gemspec]

    task :package do
      # Chain some cleanup tasks to the default :package task.
      # Remove the gemfile if it wasn't actually requested.
      unless @need_gem
        puts "  Gem file not requested. Removed."
        system "rm pkg/*.gem"
      end
      # Remove the generated gemspec once the packaging is done, to discourage people from modifying it by hand.
      if include_gemspec and File.exist? gemspec_name and not retain_gemspec
        File.delete gemspec_name
      end

      # Test signing status
      if private_key and File.exist? private_key
        puts "Signing gem."
      else
        raise "Key required, but not found. Maybe you forget to set ENV['GEM_PRIVATE_KEY']?" if require_signed
        puts "Private key not found; gem will not be signed."
      end
      puts "Targeting \"#{platform}\" platform."
    end

    desc 'Install the gem'
    task :install => [:clean, :package, :uninstall] do
      system "#{'sudo' if use_sudo} #{gem_bin} install pkg/*.gem --no-update-sources #{'-P MediumSecurity' if private_key and File.exist?(private_key)}"
    end

    namespace :install do
      desc 'Install the gem including development dependencies'
      task :development => [:clean, :package, :uninstall] do
        system "#{'sudo' if use_sudo} #{gem_bin} install pkg/*.gem -P MediumSecurity --no-update-sources --development"
      end
    end

    desc 'Uninstall the gem'
    task :uninstall do
      system "#{'sudo' if use_sudo} #{gem_bin} uninstall #{name} -a -I -x"
    end

    desc 'Override this task to add prerelease checks'
    task :prerelease

    desc 'Package and upload the release to Gemcutter'
    task :release => [:prerelease, :clean, :package] do |t|
      git_branch = nil
      if (File.exist?(".git"))
        git_branch = `git branch --no-color | egrep '^\\*' | awk '{print $2}'`.chomp
        if (`git diff origin/#{git_branch}`).any?
          puts "You need to commit and push your changes first."
          exit(1)
        end
      end
      tag = "#{name}-#{version}"
      pkg = "pkg/#{tag}"
      pkg_gem = pkg + ".gem"
      pkg_tar = pkg + ".tgz"
      pkg_tar_gz = pkg + ".tar.gz"
      pkg_zip = pkg + ".zip"

      puts "Releasing #{name} v. #{version}  to Gemcutter."
      if system("gem push #{pkg_gem.inspect}")
        if git_branch
          if system("git tag #{tag} && git push origin #{tag}")
            puts "Tagged release as #{tag}"
          end
        end
     end
   end

    ### Extension building

    task :lib do
      directory "lib"
    end

    if extension_pattern.any?

      desc "Compile the binary extension module"
      task :compile => [:lib] do
        extension_pattern.each do |extension|
          ext_dir = File.dirname(extension)
          lib_target = nil
          Dir.chdir(ext_dir) do
            ruby File.basename(extension)
            system(RUBY_PLATFORM =~ /win32/ ? 'nmake' : 'make')
            lib_target = if(target_prefix_line = open('Makefile').readlines.grep(/target_prefix = /).first)
              target_prefix_line.split('=').last.chomp("\n").strip
            else
              ''
            end
          end
          Dir["#{ext_dir}/*.#{Config::CONFIG['DLEXT']}"].each do |file|
            dir = "lib/#{lib_target}/".gsub('//', '/')
            mkdir_p dir
            cp file, dir
          end
        end
      end

      task :test => [:compile] if test_pattern.any?
      task :spec => :compile if spec_pattern.any?

    end

    ### Cross-platform targets

    Gem::Specification::PLATFORM_CROSS_TARGETS.each do |target|
      task target do
        reset_target target
      end
    end

    ### Documentation

    Rake::RDocTask.new(:docs) do |rd|
      # rd.main = Dir['*'].detect {|f| f =~ /^readme/i}
      rd.options += Array(rdoc_options)

      rd.rdoc_dir = 'doc'
      rd.rdoc_files.push(*rdoc_pattern)

      if rdoc_template
        rd.template = rdoc_template
      elsif ENV['RDOC_TEMPLATE']
        rd.template = ENV['RDOC_TEMPLATE']
      elsif `allison --path`.any?
        rd.template = `allison --path`.chomp
      end
    end

    task :doc => [:redocs]

    desc "Publish documentation to the internet."
    task :publish_docs => [:clean, :docs] do

      local_dir = File.expand_path('doc')

      if docs_host =~ /git@github.com/
        Dir.mktmpdir do |dir|
          Dir.chdir(dir) do
            puts "Working in: #{dir}"
            cmd = "git clone #{docs_host}"
            puts "Cloning existing docs: #{cmd}"
            system(cmd)

            repository_name = docs_host.split("/").last
            Dir.chdir(repository_name) do
              project_dir_name = project
              Dir.mkdir(project_dir_name) rescue nil

              project_dir_name += "/#{name}" if project != name
              Dir.mkdir(project_dir_name) rescue nil

              cmd = "rm -rf '#{project_dir_name}' && mv #{local_dir} '#{project_dir_name}'"
              puts("Moving docs into checkout: #{cmd}")
              system(cmd)

              cmd = "git add '#{project_dir_name}' && git commit -a -m 'Update documentation for #{name} #{version}'"
              puts "Committing changes: #{cmd}"
              system(cmd)

              cmd = "git push"
              puts "Pushing changes: #{cmd}"
              system(cmd)
            end
          end
        end
      else
        # you may need ssh keys configured for this to work
        remote_dir_name = project
        remote_dir_name += "/#{name}" if project != name
        host, dir = docs_host.split(":")
        dir.chomp!("/")

        # XXX too dangerous?
        cmd = "ssh #{host} 'rm -rf #{dir}/#{remote_dir_name}'"
        puts "Deleting existing docs: #{cmd}"
        system(cmd)

        cmd = "scp -qr #{local_dir} #{host}:#{dir}/#{remote_dir_name}"
        puts "Uploading: #{cmd}"
        system(cmd)
      end
    end

    desc 'Generate a release announcement, edit it, and post it to Rubyforge.'
    task :announce do

      filename = "#{Dir.tmpdir}/#{name}_#{version}_announcement.txt"

      if File.exist?(filename)
        puts "Announcement file already exists. Please delete #{filename.inspect} first."
        exit(1)
      end

      File.open(filename, 'w') do |f|
        f.write "Subject: #{name.capitalize} #{version}\n\n"
        f.write "#{name.capitalize} has been updated to #{version}. #{name.capitalize} is #{summary.uncapitalize}\n\n"
        unless changes.empty?
          f.write "Changes in this version: "
          if changes.include?("\n")
            f.write(changes)
          else
            f.write(changes.sub(/^\s*[\w\d\.]+\s+/, '').uncapitalize)
          end
          f.write("\n\n")
        end
        f.write "More information is available at #{url} .\n\n" unless url.empty?
      end

      editor = ENV['EDITOR'] || 'nano'
      system("#{editor} #{filename}") or raise "Editor '#{editor}' failed to start"
      puts File.open(filename).read

      File.open(filename).readlines.detect { |line| line =~ /Subject: (.*)/ }
      subject = $1 or raise "Subject line seems to have disappeared"

      body = File.open(filename).readlines.reject { |line| line =~ /Subject: / }.join.gsub("\n\n\n", "\n\n")

      rf = RubyForge.new.configure
      rf.login
      rf.post_news(project, subject, body)
      puts "Published announcement to Rubyforge."
      File.delete filename
    end

    ### Clean

    desc 'Clean up auto-generated files'
    task :clean do
      puts "Cleaning"
      clean_pattern.each do |file|
        if File.exist?(file)
          puts "- #{file}"
          rm_rf file
        end
      end
    end

    ### Manifest

    desc "Build a Manifest list"
    task :manifest => [:clean] do
      puts "Building Manifest"
      old_files = files
      files = []
      Dir['**/**'].sort.each do |file|
        next unless file
        next if ignore_pattern.include?(file)
        next if File.directory?(file)
        next if !include_rakefile and file == rakefile_name
        files << file
      end

      files << rakefile_name if include_rakefile
      files << manifest_name
      files.uniq!

      File.open(manifest_name, 'w').puts(files)

      (files | old_files).sort.each do |file|
        next if file == gemspec_name
        sign = " "
        if old_files.include?(file) and !files.include?(file)
          sign = "-"
        elsif files.include?(file) and !old_files.include?(file)
          sign = "+"
        end
        puts "#{sign} #{file}"
      end
    end

    task :build_manifest => :manifest

    ### Testing

    if test_pattern.any?
      Rake::TestTask.new(:test_inner) do |t|
        t.libs = ['lib', 'ext', 'bin', 'test']
        t.test_files = test_pattern
        t.verbose = true
      end

      desc "Run the test suite"
      task :test do
        if File.exist? 'test/setup.rb'
          Echoe.silence do
            puts "Setting up test environment"
            system("ruby test/setup.rb")
          end
        end
        begin
          test = Rake::Task[:test_inner]
          if test.respond_to? :already_invoked=
            # Method provided by MultiRails
            test.already_invoked = false
          end
          test.invoke
        ensure
          if File.exist? 'test/teardown.rb'
            Echoe.silence do
              puts "Tearing down test environment"
              system("ruby test/teardown.rb")
            end
          end
        end
      end

      task :default => :test
    else
      task :default do
        puts "Nothing to do."
      end
    end

    if defined? Spec and spec_pattern.any?
      desc "Run the spec suite"
      Spec::Rake::SpecTask.new('spec') do |t|
        t.spec_files = spec_pattern
      end

      task :default => :spec
    end

    if defined? Rcov
      Rcov::RcovTask.new(:coverage) do |t|
        t.test_files = test_pattern
        t.rcov_opts << rcov_options if rcov_options
        t.verbose = true
      end
      task :rcov => :coverage
    end

    # Irb console
    desc 'Start an irb session and load the library.'
    task :console do
      exec "irb -I lib -r #{name}"
    end
  end
end

require "#{$HERE}/echoe/platform"
