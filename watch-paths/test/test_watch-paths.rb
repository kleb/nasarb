require 'test/unit'
require 'watch-paths'

require 'fileutils'
include FileUtils

class TestWatchPaths < Test::Unit::TestCase
  def setup
    mkdir 'fixture'
    cd 'fixture' do
      File.open('a_file','w'){ |f| f.puts 'contents' }
      File.open('another_file','w'){ |f| f.puts 'other contents' }
    end
    @wp = WatchPaths.new
  end
  def test_creation
    assert_not_nil @wp
  end
  def test_load_non_existent_chksum_manifest_file_returns_empty_hash
    chksum_manifest = @wp.load
    assert chksum_manifest.empty?, "chksum_manifest empty"
  end
  def test_dump_and_load
    begin
      dumped_manifest = { :file => :chksum }
      @wp.dump dumped_manifest
      assert File.exist?(WatchPaths::MANIFEST)
      loaded_manifest = @wp.load
      assert loaded_manifest == dumped_manifest
      assert_equal 1, loaded_manifest.size
    ensure
      rm_rf WatchPaths::MANIFEST
    end
  end
  def test_creates_chksum_manifest
    cd 'fixture' do
      chksum_manifest = @wp.create_chksum_manifest
      assert_equal 2, chksum_manifest.size
      assert chksum_manifest.has_key?('a_file')
      assert chksum_manifest.has_key?('another_file')
    end
  end
  def test_check_reports_chksum_changes
    @wp.watch( ['fixture'] )
    cd 'fixture' do
      File.open('a_file','w'){ |f| f.puts 'changed_contents' }
      assert_raise ChecksumError do @wp.check @wp.load end
    end
  end
  def test_watch_reports_chksum_changes
    @wp.watch( ['fixture'] )
    cd 'fixture' do
      File.open('a_file','w'){ |f| f.puts 'changed_contents' }
    end
    changes = @wp.watch( ['fixture'] )
    assert_equal 1, changes.size
    assert changes.keys.include?('fixture')
    assert_equal '["a_file"]', changes['fixture']
  end
  def teardown
    rm_rf 'fixture'
  end
end
