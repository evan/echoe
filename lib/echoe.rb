
require 'rubygems'
require 'rake'
require 'rake/contrib/sshpublisher'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rbconfig'
require 'highline/import'
gem 'rubyforge', '>= 0.4.0'
require 'rubyforge'



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
  attr_accessor :author, :changes, :clean_pattern, :description, :email, :extra_deps, :name, :need_tar, :need_tar_gz, :need_zip, :rdoc_pattern, :rubyforge_name, :summary, :test_patterns, :url, :version, :docs_host, :rdoc_template, :manifest_name
  
  # best left alone
  attr_accessor :lib_files, :test_files, :bin_files, :spec
  
  def initialize(name, version = nil)
    # Defaults

    self.name = name
    self.rubyforge_name = name.downcase
    self.url = ""
    self.author = ""
    self.email = ""
    self.clean_pattern = %w(diff diff.txt email.txt ri *.gem **/*~)
    self.test_patterns = ['test/**/test_*.rb']
    
    self.version = if version
      version
    elsif File.exist? "CHANGELOG"
      open("CHANGELOG").read[/^v([\d\.]+)\. /, 1]
    else
      raise "No version supplied in Rakefile"
    end

    self.changes = if File.exist? "CHANGELOG"
      open("CHANGELOG").read[/^v([\d\.]+\. .*)/, 1]
    else
      ""
    end
        
    self.description = ""
    self.summary = ""
    self.rdoc_pattern = /^(lib|bin|tasks)|README|CHANGELOG|LICENSE|txt$/
    self.extra_deps = []
    self.manifest_name = "Manifest"

    self.need_tar = false    
    self.need_tar_gz = true
    self.need_zip = false

    yield self if block_given?

    define_tasks
  end

  def define_tasks
    task :default => :test

    desc 'Run the test suite'
    task :test do
      run_tests
    end

    ############################################################
    # Packaging and Installing

    self.spec = Gem::Specification.new do |s|
      s.name = name
      s.version = version
      s.summary = summary
      s.author = Array(author).join(", ")
      s.email = email
      s.homepage = url
      s.rubyforge_project = rubyforge_name

      s.description = description

      extra_deps.each do |dep|
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
      s.require_paths = dirs unless dirs.empty?
      s.has_rdoc = true

      if File.exist? "test/test_all.rb"
        s.test_file = "test/test_all.rb"
      else
        s.test_files = Dir[*test_patterns]
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
                 pkg_gem].compact
  
        puts "Releasing #{name} v. #{version}"
        self.version = self.version.ljust(3)
  
        begin
          rf.add_release rubyforge_name, name, version, *files
        rescue NoMethodError
        end
      end
      
    end

    Rake::RDocTask.new(:docs) do |rd|      
      rd.main = Dir['*'].detect {|f| f =~ /^readme/i}
      rd.options << '--line-numbers' << '--inline-source'
      rd.rdoc_dir = 'doc'

      files = (spec.files.grep(rdoc_pattern) - [manifest_name]).uniq
      rd.rdoc_files.push *files

      if rdoc_template
        rd.template = rdoc_template 
      elsif ENV['RDOC_TEMPLATE'] and File.exist? ENV['RDOC_TEMPLATE']
        rd.template = ENV['RDOC_TEMPLATE']
      end      

      title = name.downcase == name ? name.capitalize : name
      rd.options << "-t #{title}"
    end

    desc "Publish documentation to #{docs_host ? "'#{docs_host}'" : "rubyforge"}"
    task :publish_docs => [:clean, :docs] do

      local_dir = 'doc'
      remote_dir_name = rubyforge_name
      remote_dir_name += "/#{name}" if rubyforge_name != name

      unless docs_host  
        config = YAML.load(File.read(File.expand_path("~/.rubyforge/user-config.yml")))
        pub = Rake::SshDirPublisher.new "#{config["username"]}@rubyforge.org", 
          "/var/www/gforge-projects/#{remote_dir_name}", 
          local_dir
        if rubyforge_name != name then
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
        
    task :doc => [:docs]

    desc 'Delete the generated documentation and packages'
    task :clean => [ :clobber_docs, :clobber_package ] do
      clean_pattern.each do |pattern|
        files = Dir[pattern]
        rm_rf files unless files.empty?
      end
    end

    desc "Build a Manifest list"
    task :build_manifest do
      files = []
      Find.find '.' do |file|
        file = file[2..-1]
        unless !file or file =~ /^(pkg|doc)|\.svn|CVS|\.bzr/ or File.directory? file
          files << file
        end
      end
      files = (files << manifest_name).uniq
      File.open(manifest_name, 'w').puts files
      puts files
    end
  end

  def run_tests # :nodoc:
    ruby(if File.exist? 'test/test_all.rb'
      "#{RUBY_FLAGS} test/test_all.rb #{FILTER}"
    else
      tests = test_patterns.map { |g| Dir.glob(g) }.flatten << 'test/unit'
      tests.map! {|f| %Q(require "#{f}")}
      "#{RUBY_FLAGS} -e '#{tests.join("; ")}' #{FILTER}"
    end)
  end

end

class ::Rake::SshDirPublisher # :nodoc:
  attr_reader :host, :remote_dir, :local_dir
end
