
require 'test/unit/testcase'
require 'echoe'

$rakefile = nil # shuts up a warning in rdoctask.rb

class TestEchoe < Test::Unit::TestCase
  def setup
    Rake.application.clear
  end

  def test_basics
    boring = %w(clobber clobber_docs clobber_package doc doc/index.html pkg pkg/blah-1.0.0 pkg/blah-1.0.0.gem pkg/blah-1.0.0.tar.gz redocs repackage default)
    expected = %w(clean clobber clobber_docs clobber_package docs gem install manifest package publish_docs redocs release repackage test uninstall build_manifest)
    expected += boring

    Echoe.new('blah', '1.0.0')
    tasks = Rake.application.tasks.map { |t| t.name }
    assert((expected - tasks).empty?)
    assert((tasks - expected).empty?)
  end
end
