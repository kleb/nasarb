#! /usr/bin/env ruby

$:.unshift File.join( File.dirname(__FILE__), '..', 'lib' )

require 'test/unit'
require 'funit/functions'

class TestCompiler < Test::Unit::TestCase

 def setup
  @compilerStub = 'dummyCompiler'
  @oldCompilerName = ENV['FC']
 end

 def test_explicit_compiler_name
  assert_equal @compilerStub, Funit::Compiler.new(@compilerStub).name
 end

 def test_compiler_name_from_environment
  ENV['FC'] = @compilerStub
  assert_equal @compilerStub, Funit::Compiler.new.name
 end  

 def test_no_environment_compiler_name
  ENV['FC'] = nil
  assert_raises(RuntimeError) {Funit::Compiler.new}
 end  

 def teardown
   ENV['FC'] = @oldCompilerName
 end

end
