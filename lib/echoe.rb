
require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/contrib/sshpublisher'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rbconfig'
require 'open-uri'
require 'highline/import'
gem 'rubyforge', '>=0.4.0'
require 'rubyforge'

=begin rdoc

Echoe includes some optional accessors for more advanced gem configuration.

For example, a simple <tt>Rakefile</tt> might look like this:

  Echoe.new("uncapitalizer") do |p|
    p.author = "Evan Weaver"
    p.summary = "A library that uncapitalizes strings. It's awesome."
    p.url = "http://www.uncapitalizer.com"
    p.docs_host = "uncapitalizer.com:~/www/files/doc/"
    p.dependencies = ["string_tools >=1.4.0"]
  end

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

Echoe does not force packages to depend on Echoe itself. Instead, it generates a <tt>gemspec</tt> from your <tt>Rakefile</tt> and includes that, along with a comment containing the original <tt>Rakefile</tt> source. Downstream repackagers can use the <tt>gemspec</tt> as-is to build new versions of your gem. This way no dependencies are added, but no contents are lost.

If you do want metadependencies, add <tt>'echoe'</tt> to the <tt>p.dependencies</tt> array, and set <tt>p.include_rakefile = true</tt> and <tt>p.include_gemspec = false</tt>.

== Accessor options

Descriptive options:

* <tt>author</tt> - Your name.
* <tt>email</tt> - Your email address.
* <tt>description</tt> - A more detailed description of the library.
* <tt>summary</tt> - A shorter description of the library.
* <tt>url</tt> - A url for the library.
* <tt>install_message</tt> - A message to display after the gem is installed.

Versioning options:

* <tt>version</tt> - A string for the version number. Parsed from CHANGELOG otherwise.
* <tt>changes</tt> - A string describing the most recent changes. Parsed from CHANGELOG otherwise.

Common packaging options:

* <tt>dependencies</tt> - An array of dependencies for this gem, in 'gem_name [= version]' format.
* <tt>extensions</tt> - Any extension files that need to be executed (defaults to <tt>"ext/**/extconf.rb"</tt>).
* <tt>clean_pattern</tt> - A filename array, glob array, or regex for files that should be removed when <tt>rake clean</tt> is run.
* <tt>test_pattern</tt> - A filename array, glob array, or regex for test runners. Defaults to <tt>"test/test_all.rb"</tt> if it exists.

Uncommon packaging options:
* <tt>platform</tt> - What platform this gem is for.
* <tt>manifest_name</tt> - The name of the manifest file (defaults to <tt>Manifest</tt>).
* <tt>need_gem</tt> - Whether to generate a gem package (default <tt>true</tt>).
* <tt>need_tar_gz</tt> - Whether to generate a <tt>.tar.gz</tt> package (default <tt>true</tt>).
* <tt>need_tgz</tt> - Whether to generate a <tt>.tgz</tt> package (default <tt>false</tt>).
* <tt>need_zip</tt> - Whether to generate a <tt>.zip</tt> package (default <tt>false</tt>).
* <tt>include_rakefile</tt> - Include the Rakefile directly within the package. Default <tt>false</tt>.
* <tt>include_gemspec</tt> - Include the generated gemspec file within the package. Default <tt>true</tt>.
* <tt>ruby_version</tt> - Version string for which Ruby to require (for example, <tt>'>= 1.8.4'</tt>).
* <tt>eval</tt> - Accepts a proc to be evaluated in the context of the Gem::Specification object. This allows you to set more unusual gemspec options.

Security options:

* <tt>private_key</tt> - The path to your gem private key. Defaults to ENV['GEM_PRIVATE_KEY'], if available. This accessor is not published in the resulting gemspec.
* <tt>certificate_chain</tt> - An array representing your certificate authorization chain. If no one else has signed your certificate, just set it to your own cert. Defaults to ENV['GEM_CERTIFICATE_CHAIN'], if available. This accessor is not published in the resulting gemspec.
* <tt>require_signed</tt> - Force Echoe to refuse to package your gem if it's not properly signed. Default false.

Publishing options:

* <tt>project</tt> - The name of the Rubyforge project to upload to (defaults to the name of the gem).
* <tt>docs_host</tt> - A host and filesystem path to publish the documentation to (defaults to the Rubyforge project).

Documentation options:

* <tt>rdoc_files</tt> - A filename array, glob array, or regex for filenames that should be passed to RDoc. Also can be referred to as <tt>rdoc_pattern</tt>.
* <tt>rdoc_template</tt> - A path to an RDoc template (defaults to the generic template).

=end

class Echoe

  rubyprefix = Config::CONFIG['prefix']
  sitelibdir = Config::CONFIG['sitelibdir']

  PREFIX = ENV['PREFIX'] || rubyprefix
  RUBYLIB = if PREFIX == rubyprefix then
              sitelibdir
            else
              File.join(PREFIX, sitelibdir[rubyprefix.size..-1])
            end
  RUBY_DEBUG = ENV['RUBY_DEBUG']
  RUBY_FLAGS = ENV['RUBY_FLAGS'] ||
    "-w -I#{%w(lib ext bin test).join(File::PATH_SEPARATOR)}" +
    (RUBY_DEBUG ? " #{RUBY_DEBUG}" : '')
  FILTER = ENV['FILTER'] # for tests (eg FILTER="-n test_blah")
  
  # user-configurable
  attr_accessor :author, :changes, :clean_pattern, :description, :email, :dependencies, :need_tgz, :need_tar_gz, :need_gem, :need_zip, :rdoc_files, :project, :summary, :test_pattern, :url, :version, :docs_host, :rdoc_template, :manifest_name, :install_message, :extensions, :private_key, :certificate_chain, :require_signed, :ruby_version, :platform
  
  # best left alone
  attr_accessor :name, :lib_files, :test_files, :bin_files, :spec, :rdoc_options, :rubyforge_name, :has_rdoc, :include_gemspec, :include_rakefile, :gemspec_name, :eval
  
  # legacy
  attr_accessor :extra_deps, :rdoc_pattern
  
  def initialize(name, version = nil)
    # Defaults

    self.name = name
    self.project = name.downcase
    self.url = ""
    self.author = ""
    self.email = ""
    self.clean_pattern = ["pkg", "doc", "lib/*.#{Config::CONFIG['DLEXT']}", "ext/**/*.#{Config::CONFIG['DLEXT']}", ".config"]
    self.test_pattern = ['test/**/test_*.rb']
    
    self.version = if version
      version
    elsif File.exist? "CHANGELOG"
      open("CHANGELOG").read[/^\s*v([\d\.]+)\. /, 1]
    else
      raise "No version supplied in Rakefile"
    end

    self.changes = if File.exist? "CHANGELOG"
      open("CHANGELOG").read[/^\s*v([\d\.]+\. .*)/, 1]
    else
      ""
    end
        
    self.description = ""
    self.summary = ""
    self.install_message = nil
    self.has_rdoc = true
    self.rdoc_files = /^(lib|bin|tasks)|^README|^CHANGELOG|^TODO|^LICENSE|^COPYING$/
    self.rdoc_options = ['--line-numbers', '--inline-source']
    self.dependencies = []
    self.manifest_name = "Manifest"
    self.extensions = ["ext/extconf.rb"] if File.exist?("ext/extconf.rb")
    self.private_key = ENV['GEM_PRIVATE_KEY']
    self.require_signed = false
    self.certificate_chain = ENV['GEM_CERTIFICATE_CHAIN'].to_s.split(/\,\s*/).compact

    self.need_gem = true
    self.need_tar_gz = true
    self.need_tgz = false    
    self.need_zip = false

    self.include_rakefile = false
    self.include_gemspec = true    
    self.gemspec_name = "#{name}.gemspec"

    yield self if block_given?
    
    # set some post-defaults
    self.certificate_chain = Array(certificate_chain)
    self.description = summary if description.empty?
    self.summary = description if summary.empty?
    self.extensions = Array(extensions) if extensions
    self.clean_pattern = Array(clean_pattern) if clean_pattern
    
    # legacy compatibility
    self.dependencies = extra_deps if extra_deps and dependencies.empty?
    self.project = rubyforge_name if rubyforge_name
    self.rdoc_files = rdoc_pattern if rdoc_pattern

    define_tasks
  end

  def define_tasks

    ### Packaging and Installing
    
    self.spec = Gem::Specification.new do |s|
      s.name = name
      s.version = version
      s.summary = summary
      s.author = Array(author).join(", ")
      s.email = email
      s.homepage = url
      s.rubyforge_project = project
      s.post_install_message = install_message if install_message
      s.description = description
      s.required_ruby_version = ruby_version
      s.platform = platform if platform

      if private_key and File.exist? private_key
        s.signing_key = private_key
        s.cert_chain = certificate_chain
      end

      dependencies.each do |dep|
        dep = dep.split(" ") if dep.is_a? String
        s.add_dependency(*dep)
      end

      begin
        s.files = File.read(manifest_name).split
        s.files += [gemspec_name] if include_gemspec
        s.files += ["Rakefile"] if include_rakefile
        s.files.uniq! # not really necessary
      rescue Errno::ENOENT
        unless ARGV.include? "manifest"
          puts "Missing manifest. You can build one with 'rake manifest'."
          exit 
        end
      end
      s.executables = s.files.grep(/bin/) { |f| File.basename(f) }

      s.bindir = "bin"
      dirs = Dir['{lib,ext}']
      s.extensions = extensions
      s.require_paths = dirs unless dirs.empty?
      s.has_rdoc = has_rdoc

      if File.exist? "test/test_all.rb"
        s.test_file = "test/test_all.rb"
      else
        s.test_files = Dir[*test_pattern]
      end
      
      if eval
        s.instance_eval &eval
      end
      
    end

    self.lib_files = spec.files.grep(/^lib/)
    self.bin_files = spec.files.grep(/^bin/)
    self.test_files = spec.files.grep(/^test/)

    Rake::GemPackageTask.new(spec) do |pkg|
      pkg.need_tar = @need_tgz
      pkg.need_tar_gz = @need_tar_gz
      pkg.need_zip = @need_zip
    end
        
    task :build_gemspec do
      # Construct the gemspec file, if needed.
      if include_gemspec
        File.open(gemspec_name, 'w') do |f|          
          f.puts "\n# Gem::Specification for #{name.capitalize}-#{version}\n# Originally generated by Echoe\n\n"
          spec.to_ruby.split("\n").each do |line|
            # Don't publish any information about the private key or certificate chain
            f.puts line unless line =~ /signing_key|cert_chain|\.pem/
          end
          
          f.puts "\n\n# # Original Rakefile source (requires the Echoe gem):\n# \n"
          File.open("Rakefile").readlines.each do |line|
            # Ditto
            f.write "# #{line}" unless line =~ /private_key|certificate_chain|\.pem/        
          end                    
        end
      end      
    end
    
    # Chain it to the gemspec task prerequisite
    task gemspec_name.to_sym => [:build_gemspec] 
        
    task :package do
      # Chain some cleanup tasks to the default :package task.
      # Remove the gemfile if it wasn't actually requested. 
      unless @need_gem
        puts "  Gem file not requested. Removed."
        system "rm pkg/*.gem"
      end
      # Remove the generated gemspec once the packaging is done, to discourage people from modifying it by hand.
      if include_gemspec and File.exist? gemspec_name
        File.delete gemspec_name
      end
      
      # Test signing status
      if private_key and File.exist? private_key
        puts "Signing gem."
      else
        raise "Key required, but not found. Maybe you forget to set ENV['GEM_PRIVATE_KEY']?" if require_signed
        puts "Private key not found; gem will not be signed."
      end      
    end  

    desc 'Install the gem'
    task :install => [:clean, :package] do
      sh "sudo gem install pkg/*.gem -P MediumSecurity"
    end

    desc 'Uninstall the gem'
    task :uninstall do
      sh "sudo gem uninstall #{name} -a -i -x"
    end

    desc 'Package and upload the release to Rubyforge'
    task :release => [:clean, :package] do |t|      
      
      say "\n"
      if agree "Release #{name}-#{version} to Rubyforge? "      
        pkg = "pkg/#{name}-#{version}"
        pkg_gem = pkg + ".gem"
        pkg_tar = pkg + ".tgz"
        pkg_tar_gz = pkg + ".tar.gz"
        pkg_zip = pkg + ".zip" 
        
        rf = RubyForge.new
        puts "Logging in"
        rf.login
  
        c = rf.userconfig
        c["release_notes"] = description if description
        c["release_changes"] = changes if changes
        c["preformatted"] = false
  
        files = [(@need_tgz ? pkg_tar : nil),
                  (@need_tar_gz ? pkg_tar_gz : nil),
                  (@need_zip ? pkg_zip : nil),
                  (@need_gem ? pkg_gem : nil)].compact
  
        puts "Releasing #{name} v. #{version}"
        self.version = self.version.ljust(3)
          
        rf.add_release project, name, version, *files
      end
      
    end
    
    ### Extension building

    task :lib do
      directory "lib"
    end
    
    task :compile => [:lib] do    
      extensions.each do |extension|
        directory = File.dirname(extension)
        Dir.chdir(directory) do 
          ruby File.basename(extension)
          sh(PLATFORM =~ /win32/ ? 'nmake' : 'make')
        end
        Dir["#{directory}/*.#{Config::CONFIG['DLEXT']}"].each do |file|
          cp file, "lib"
        end
      end
    end
    
    if extensions and extensions.any?
      task :test => [:compile]
    end
    
    ### Documentation

    Rake::RDocTask.new(:docs) do |rd|      
      rd.main = Dir['*'].detect {|f| f =~ /^readme/i}
      rd.options += Array(rdoc_options)
      
      rd.rdoc_dir = 'doc'
      
      files = case rdoc_files
        when Array
          rdoc_files.map do |pattern|
            Dir[pattern].select { |file| spec.files.include? file }
          end.flatten
        when Regexp
          spec.files.grep(rdoc_files).uniq
        else
          []
      end
      
      files -= [manifest_name]
      
      rd.rdoc_files.push(*files)

      if rdoc_template
        rd.template = rdoc_template 
      elsif ENV['RDOC_TEMPLATE'] and File.exist? ENV['RDOC_TEMPLATE']
        rd.template = ENV['RDOC_TEMPLATE']
      end      

      title = name.downcase == name ? name.capitalize : name
      rd.options << "-t #{title}"
    end
        
    task :doc => [:redocs]

    desc "Publish documentation to #{docs_host ? "'#{docs_host}'" : "rubyforge"}"
    task :publish_docs => [:clean, :docs] do

      local_dir = 'doc'
      remote_dir_name = project
      remote_dir_name += "/#{name}" if project != name

      unless docs_host  
        config = YAML.load(File.read(File.expand_path("~/.rubyforge/user-config.yml")))
        pub = Rake::SshDirPublisher.new "#{config["username"]}@rubyforge.org", 
          "/var/www/gforge-projects/#{remote_dir_name}", 
          local_dir
        if project != name then
          def pub.upload
            begin
              super
            rescue
              # project directory probably doesn't exist, transfer as a whole
              sh("scp -qr #{local_dir} #{host}:#{remote_dir}")
            end
          end
        end
        pub.upload        
      else
        # you may need ssh keys configured for this to work
        host, dir = docs_host.split(":")
        dir.chomp!("/")
        sh("ssh #{host} 'rm -rf #{dir}/#{remote_dir_name}'") # XXX too dangerous?
        sh("scp -qr #{local_dir} #{host}:#{dir}/#{remote_dir_name}")
      end      
    end
        
    desc 'Generate a release announcement, edit it, and post it to Rubyforge.'
    task :announce do
      
      filename = "/tmp/#{name}_#{version}_announcement.txt"
      
      if !File.exist?(filename) or agree "Overwrite existing announcement file? "        
        File.open(filename, 'w') do |f|
          f.write "Subject: #{name.capitalize} #{version}\n\n"
          f.write "#{name.capitalize} has been updated to #{version}. #{name.capitalize} is #{summary.uncapitalize}\n\n"
          f.write "Changes in this version: #{changes.sub(/^\s*[\w\d\.]+\s+/, '').uncapitalize}\n\n" unless changes.empty?
          f.write "More information is available at #{url} .\n\n" unless url.empty?
        end
      end
      
      begin        
        system("nano #{filename}") or raise "Editor returned an error"
        puts File.open(filename).read
      end while !agree "Done editing? "
      
      if agree "Publish announcement to Rubyforge? "
        File.open(filename).readlines.detect { |line| line =~ /Subject: (.*)/ }
        subject = $1 or raise "Subject line seems to have disappeared"
        
        body = File.open(filename).readlines.reject { |line| line =~ /Subject: / }.join.gsub("\n\n\n", "\n\n")
        
        rf = RubyForge.new
        rf.login
        rf.post_news(project, subject, body)
        puts "Published."
        File.delete filename
      end
    end    
    
    ### Clean

    desc 'Clean up auto-generated files'
    task :clean do
      clean_pattern.each do |pattern|
        files = Dir[pattern]
        rm_rf files unless files.empty?
      end
    end
    
    ### Manifest

    desc "Build a Manifest list"
    task :manifest do
      files = []
      Find.find '.' do |file|
        file = file[2..-1]
        next unless file
        next if file =~ /^(pkg|doc)|\.svn|CVS|\.bzr|\.DS|\.git/
        next if File.directory?(file)
        next if !include_rakefile and file == "Rakefile"
        files << file
      end

      files << "Rakefile" if include_rakefile
      files << manifest_name
      files.uniq!
      
      File.open(manifest_name, 'w').puts(files)
      puts(files)
    end
    
    task :build_manifest => [:manifest]
  
    ### Tests
  
    # XXX unreadable
    desc 'Run the test suite'
    task :test do
      ruby(if File.exist? 'test/test_all.rb'
        "#{RUBY_FLAGS} test/test_all.rb #{FILTER}"
      else
        tests = test_pattern.map { |g| Dir.glob(g) }.flatten << 'test/unit'
        tests.map! {|f| %Q(require "#{f}")}
        "#{RUBY_FLAGS} -e '#{tests.join("; ")}' #{FILTER}"
      end)
    end
  
    task :default => :test
    
  end
end

class ::Rake::SshDirPublisher # :nodoc:
  attr_reader :host, :remote_dir, :local_dir
end

class String #:nodoc:
  def uncapitalize #:nodoc:
    "#{self[0..0].downcase}#{self[1..-1]}"
  end
end

