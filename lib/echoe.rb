
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

For example, Echoe's own <tt>Rakefile</tt> looks like this:

  Echoe.new('echoe') do |p|
    p.project = 'fauna'
    p.author = 'Evan Weaver'
    p.summary = 'A tool for packaging Ruby gems.'
    p.url = 'http://blog.evanweaver.com/pages/code#echoe'
    p.docs_host = 'blog.evanweaver.com:~/www/snax/public/files/doc/'
    p.dependencies = ['rake', 'rubyforge >=0.4.3', 'highline']
  end

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

Packaging options:

* <tt>dependencies</tt> - An array of dependencies for this gem, in 'gem_name [= version]' format.
* <tt>manifest_name</tt> - The name of the manifest file (defaults to <tt>Manifest</tt>).
* <tt>need_gem</tt> - Whether to generate a gem package (default <tt>true</tt>).
* <tt>need_tar_gz</tt> - Whether to generate a <tt>.tar.gz</tt> package (default <tt>true</tt>).
* <tt>need_tar</tt> - Whether to generate a <tt>.tgz</tt> package (default <tt>false</tt>).
* <tt>need_zip</tt> - Whether to generate a <tt>.zip</tt> package (default <tt>false</tt>).
* <tt>extensions</tt> - Any extension files that need to be executed (defaults to "ext/extconf.rb" if it exists).

Publishing options:

* <tt>project</tt> - The name of the Rubyforge project to upload to (defaults to the name of the gem).
* <tt>docs_host</tt> - A host and filesystem path to publish the documentation to (defaults to the Rubyforge project).
* <tt>announce</tt> - Generate a release announcement, edit it, and post it to Rubyforge.

Documentation options:

* <tt>rdoc_pattern</tt> - A regex for filenames that should be passed to RDoc.
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
  attr_accessor :author, :changes, :clean_pattern, :description, :email, :dependencies, :need_tar, :need_tar_gz, :need_gem, :need_zip, :rdoc_pattern, :project, :summary, :test_pattern, :url, :version, :docs_host, :rdoc_template, :manifest_name, :install_message, :extensions
  
  # best left alone
  attr_accessor :name, :lib_files, :test_files, :bin_files, :spec, :rdoc_options, :rubyforge_name, :has_rdoc
  
  # legacy
  attr_accessor :extra_deps
  
  def initialize(name, version = nil)
    # Defaults

    self.name = name
    self.project = name.downcase
    self.url = ""
    self.author = ""
    self.email = ""
    self.clean_pattern = %w(diff diff.txt email.txt ri *.gem **/*~)
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
    self.rdoc_pattern = /^(lib|bin|tasks)|^README|^CHANGELOG|^TODO|^LICENSE$/
    self.rdoc_options = ['--line-numbers', '--inline-source']
    self.dependencies = []
    self.manifest_name = "Manifest"
    self.extensions = ["ext/extconf.rb"] if File.exist?("ext/extconf.rb")

    self.need_gem = true
    self.need_tar_gz = true
    self.need_tar = false    
    self.need_zip = false

    yield self if block_given?
    
    # set some post-defaults
    self.description = summary if description.empty?
    self.summary = description if summary.empty?
    
    # legacy compatibility
    self.dependencies = extra_deps if extra_deps and dependencies.empty?
    self.project = rubyforge_name if rubyforge_name

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

      dependencies.each do |dep|
        dep = dep.split(" ") if dep.is_a? String
        s.add_dependency(*dep)
      end

      begin
        s.files = File.read(manifest_name).split
      rescue Errno::ENOENT
        $stderr.puts "Missing Manifest. You can build one with\n$ rake build_manifest."
      end
      s.executables = s.files.grep(/bin/) { |f| File.basename(f) }

      s.bindir = "bin"
      dirs = Dir['{lib,ext}']
      s.extensions = Array(extensions) if extensions
      s.require_paths = dirs unless dirs.empty?
      s.has_rdoc = has_rdoc

      if File.exist? "test/test_all.rb"
        s.test_file = "test/test_all.rb"
      else
        s.test_files = Dir[*test_pattern]
      end

    end

    self.lib_files = spec.files.grep(/^lib/)
    self.bin_files = spec.files.grep(/^bin/)
    self.test_files = spec.files.grep(/^test/)

    Rake::GemPackageTask.new spec do |pkg|
      pkg.need_tar = @need_tar
      pkg.need_tar_gz = @need_tar_gz
      pkg.need_zip = @need_zip
    end
    
    task :package do
      # remove the gemfile if it wasn't actually requested
      unless @need_gem
        puts "  Gem file not requested. Removed."
        system "rm pkg/*.gem"
      end
    end      

    desc 'Install the gem'
    task :install => [:clean, :package] do
      sh "sudo gem install pkg/*.gem"
    end

    desc 'Uninstall the gem'
    task :uninstall do
      sh "sudo gem uninstall #{name}"
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
  
        files = [(@need_tar ? pkg_tar : nil),
                  (@need_tar_gz ? pkg_tar_gz : nil),
                  (@need_zip ? pkg_zip : nil),
                  (@need_gem ? pkg_gem : nil)].compact
  
        puts "Releasing #{name} v. #{version}"
        self.version = self.version.ljust(3)
          
        rf.add_release project, name, version, *files
      end
      
    end
    
    ### Documentation

    Rake::RDocTask.new(:docs) do |rd|      
      rd.main = Dir['*'].detect {|f| f =~ /^readme/i}
      rd.options += Array(rdoc_options)
      
      rd.rdoc_dir = 'doc'

      files = (spec.files.grep(rdoc_pattern) - [manifest_name]).uniq
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
          f.write "More information is available at #{url}\n\n" unless url.empty?
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

    desc 'Delete the generated documentation and packages'
    task :clean => [ :clobber_docs, :clobber_package ] do
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
        unless !file or file =~ /^(pkg|doc)|\.svn|CVS|\.bzr|\.DS/ or File.directory? file
          files << file
        end
      end
      files = (files << manifest_name).uniq
      File.open(manifest_name, 'w').puts files
      puts files
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

