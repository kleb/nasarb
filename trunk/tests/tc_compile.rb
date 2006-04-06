$:.unshift File.join( File.dirname(__FILE__), '..', 'lib' )
require 'funit/functions'

class TestCompiler < Test::Unit::TestCase

 def set_up
  @compilerStub = 'dummyCompiler'
  @oldCompilerName = ENV['F9X']
 end

 def testExplicitCompilerName
  assert_equal @compilerStub, Funit::Compiler.new(@compilerStub).name
 end

 def testCompilerNameFromEnvironment
  ENV['F9X'] = @compilerStub
  assert_equal @compilerStub, Funit::Compiler.new.name
 end  

 def testNoEnvironmentCompilerName
  ENV['F9X'] = nil
  assert_raises(RuntimeError) {Funit::Compiler.new}
 end  

 def tear_down
   ENV['F9X'] = @oldCompilerName
 end

end
