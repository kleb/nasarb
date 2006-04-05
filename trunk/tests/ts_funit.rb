#!/usr/bin/env ruby
#
# $Id: F90testMT.rb 16233 2005-09-21 11:12:11Z kleb $

require 'test/unit'
require 'F90test'
require 'ftools'

# to make backward compatible with older testunit versions:
unless Test::Unit::TestCase.method_defined? 'assert_no_match'
 module Test; module Unit; module Assertions
  alias assert_no_match assert_does_not_match
 end; end; end
end


class CompilerMT < Test::Unit::TestCase

 def set_up
  @compilerStub = 'dummyCompiler'
  @oldCompilerName = ENV['F9X']
 end

 def testExplicitCompilerName
  assert_equal @compilerStub, Compiler.new(@compilerStub).name
 end

 def testCompilerNameFromEnvironment
  ENV['F9X'] = @compilerStub
  assert_equal @compilerStub, Compiler.new.name
 end  

 def testNoEnvironmentCompilerName
  ENV['F9X'] = nil
  assert_raises(RuntimeError) {Compiler.new}
 end  

 def tear_down
   ENV['F9X'] = @oldCompilerName
 end

 alias setup set_up
 alias teardown tear_down

end

class TestSuiteMT < Test::Unit::TestCase

 def set_up
  File.rm_f(*Dir["dummyf90test*"])
 end 

 def testNonexistentFtkFileIsNotCreated
  TestSuite.new 'dummyf90test'
  assert !File.exists?("dummyf90testMT.ftk")
  assert !File.exists?("dummyf90testMT.f90")
 end

 def createFtkFile ftkContents
  File.open('dummyf90test.f90','w') do |f|
   f.puts "module dummyf90test\nend module dummyf90test"
  end
  File.open('dummyf90testMT.ftk','w') do |f|
   f.puts ftkContents
  end
 end

 @@compileCommand = "#{Compiler.new.name} -c dummyf90test.f90 dummyf90testMT.f90"

 def testBareMinimumFtkFileCompiles
  createFtkFile ""
  TestSuite.new 'dummyf90test'
  assert system(@@compileCommand)
 end

 def testModuleVariablesAllowed
  createFtkFile "integer :: a"
  TestSuite.new 'dummyf90test'
  assert system(@@compileCommand)
 end

 def testBlankSetupCompiles
  createFtkFile "beginSetup\nendSetup"
  TestSuite.new 'dummyf90test'
  assert system(@@compileCommand)
 end

 def testBlankTestGivesWarning
  createFtkFile "beginTest bob\nendTest"
  TestSuite.new 'dummyf90test'
  assert system(@@compileCommand)
 end

 def testSingleAssertTestCompiles
  createFtkFile "beginTest assertTrue\nIsTrue(.true.)\nendTest"
  TestSuite.new 'dummyf90test'
  assert system(@@compileCommand)
 end

 def testMatrixAssertCompiles
  createFtkFile <<-MATFTK
 beginTest assertTrue
  integer :: a(2,2)
  a = 1
  IsEqual(a(1,1),1)
 endTest
  MATFTK
  TestSuite.new 'dummyf90test'
  puts `cat dummyf90testMT.ftk`
  puts `cat dummyf90testMT.f90`
  assert system(@@compileCommand)
 end

 def testIgnoreCommentedTest
  createFtkFile "XbeginTest bob\nendTest"
  TestSuite.new 'dummyf90test'
  assert_no_match( /Testbob/i, IO.readlines('dummyf90testMT.f90').join )
 end

 def tear_down
  File.rm_f(*Dir["dummyf90test*"])
 end 

 alias teardown tear_down
 alias setup set_up

end

class F90testMT < Test::Unit::TestCase
 include Asserts

 def testMainDriverCompiles
  writeTestRunner []
  assert File.exists?("TestRunner.f90")
  assert system("#{Compiler.new.name} TestRunner.f90")
  assert File.exists?("a.out")
 end

 def testIsEqual
  @suiteName = "dummy"
  @testName = "dummy"
  @lineNumber = "dummy"
  isequal("IsEqual(1.0,m(1,1))")
  assert_equal '.not.(1.0==m(1,1))', @condition
 end 

 def testIsRealEqual
  @suiteName = "dummy"
  @testName = "dummy"
  @lineNumber = "dummy"
  isrealequal("IsRealEqual(a,b)")
ans = <<EOF
.not.(a+2*spacing(real(a)).ge.b &
             .and.a-2*spacing(real(a)).le.b)
EOF
  assert_equal ans.chomp, @condition
  assert_equal '"b (",b,") is not",a,"within",2*spacing(real(a))', @message 

  isrealequal("IsRealEqual(1.0,m(1,1))")
ans = <<EOF
.not.(1.0+2*spacing(real(1.0)).ge.m(1,1) &
             .and.1.0-2*spacing(real(1.0)).le.m(1,1))
EOF
  assert_equal ans.chomp, @condition
 end

 def testHandlesDependency
  File.open('unit.f90','w') do |f|
   f.printf "module unit\n  use unita, only : a\nend module unit\n"
  end
  File.open('unita.f90','w') do |f|
   f.printf "module unita\n  integer :: a = 5\nend module unita\n"
  end
  File.open('unitMT.ftk','w') do |f|
   f.printf "beginTest A\n  IsEqual(5, a)\nendTest\n"
  end  
  assert_nothing_raised{runAllFtks}
 end

 def testEmbeddedDependencies
  File.open('unit.f90','w') do |f|
   f.printf "module unit\n  use unita, only : a\nend module unit\n"
  end
  File.open('unita.f90','w') do |f|
   f.printf "module unita\n  use unitb, only : b \n  integer :: a = b\nend module unita\n"
  end
  File.open('unitb.f90','w') do |f|
   f.printf "module unitb\n  integer,parameter :: b = 5\nend module unitb\n"
  end
  File.open('unitMT.ftk','w') do |f|
   f.printf "beginTest A\n  IsEqual(5, a)\nendTest\n"
  end  
  assert_nothing_raised{runAllFtks}
 end

 def testRequestedModules
  assert_equal ["asdfga"], requestedModules(["asdfga"])
  assert_equal ["asd","fga"], requestedModules(["asd","fga"])
  assert requestedModules([]).empty?
  modules = %w[ldfdl lmzd]
  ftks = modules.map{|f| f+'MT.ftk'}.join(' ')
  system "touch "+ftks
  assert_equal modules, requestedModules([])
 end

 def testFTKExists
  moduleName = "ydsbe"
  File.rm_f(moduleName+"MT.ftk")
  assert_equal false, ftkExists?(moduleName)
  system "touch "+moduleName+"MT.ftk"
  assert ftkExists?(moduleName)
 end

 def tear_down
  File.rm_f(*Dir["dummyunit*"])
  File.rm_f(*Dir["unit*"])
  File.rm_f(*Dir["ydsbe*"])
  File.rm_f(*Dir["lmzd*"])
  File.rm_f(*Dir["ldfdl*"])
  File.rm_f(*Dir["ydsbe*"])
  File.rm_f(*Dir["TestRunner*"])
  File.rm_f(*Dir["a.out"])
 end
 alias teardown tear_down

end
