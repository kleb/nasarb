require 'test/unit'
require 'lakos/analyze_dependencies'
require 'fileutils'

class TestAnalyzeDependencies < Test::Unit::TestCase

 def setup
  FileUtils.rm_rf 'AD_fixtures'
  Dir.mkdir 'AD_fixtures'
  Dir.chdir 'AD_fixtures'
  File.open('m.f90','w'){|f| f.puts "program m\nuse a\nuse b\nuse d\nuse f" }
  File.open('a.f90','w'){|f| f.puts "module a" }
  File.open('b.f90','w'){|f| f.puts "module b\nuse c\nuse d\nuse e" }
  File.open('c.f90','w'){|f| f.puts "module c" }
  File.open('d.f90','w'){|f| f.puts "module d" }
  File.open('e.f90','w'){|f| f.puts "module e" }
  File.open('f.f90','w'){|f| f.puts "module f\nuse c\nuse e" }
  @da = DependencyAnalyzer.new( 'm.f90', ['.'] )
  Dir.chdir '..'
  File.open('main.dot','w'){ |f| f.puts @da.graph(@da.dd_deps) }
 end

 def test_statistics
  assert_equal(  3, @da.levels.size )
  assert_equal(  7, @da.components )
  assert_equal( 18, @da.ccd )
  assert_in_delta( 18/7.to_f,  @da.acd,  Float::EPSILON )
  assert_in_delta( 18/17.to_f, @da.nccd, Float::EPSILON )
 end

 def teardown
  FileUtils.rm_rf 'AD_fixtures'
 end

end
