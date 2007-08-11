
require 'test/unit/testcase'
require 'echoe'

$rakefile = nil # Avoids a warning in rdoctask.rb

class TestEchoe < Test::Unit::TestCase
  def setup
    Rake.application.clear
  end

  def test_basics
    expected = ["announce", "blah.gemspec", "build_gemspec", "build_manifest", "clean", "clobber", "clobber_docs", "clobber_package", "default", "doc", "doc/index.html", "docs", "gem", "install", "manifest", "package", "pkg", "pkg/blah-1.0.0", "pkg/blah-1.0.0.gem", "pkg/blah-1.0.0.tar.gz", "publish_docs", "redocs", "release", "repackage", "test", "uninstall"]
    
    Echoe.new('blah', '1.0.0')
    tasks = Rake.application.tasks.map { |t| t.name }
    assert((expected - tasks).empty?)
    assert((tasks - expected).empty?)
  end
end
