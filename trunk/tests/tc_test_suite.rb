$:.unshift File.join( File.dirname(__FILE__), '..', 'lib' )
require 'funit/test_suite'

class TestTestSuite < Test::Unit::TestCase

 def set_up
  File.rm_f(*Dir["dummyf90test*"])
 end 

 def testNonexistentFtkFileIsNotCreated
  Funit::TestSuite.new 'dummyf90test'
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

 @@compileCommand = "#{Funit::Compiler.new.name} -c dummyf90test.f90 dummyf90testMT.f90"

 def testBareMinimumFtkFileCompiles
  createFtkFile ""
  Funit::TestSuite.new 'dummyf90test'
  assert system(@@compileCommand)
 end

 def testModuleVariablesAllowed
  createFtkFile "integer :: a"
  Funit::TestSuite.new 'dummyf90test'
  assert system(@@compileCommand)
 end

 def testBlankSetupCompiles
  createFtkFile "beginSetup\nendSetup"
  Funit::TestSuite.new 'dummyf90test'
  assert system(@@compileCommand)
 end

 def testBlankTestGivesWarning
  createFtkFile "beginTest bob\nendTest"
  Funit::TestSuite.new 'dummyf90test'
  assert system(@@compileCommand)
 end

 def testSingleAssertTestCompiles
  createFtkFile "beginTest assertTrue\nIsTrue(.true.)\nendTest"
  Funit::TestSuite.new 'dummyf90test'
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
  Funit::TestSuite.new 'dummyf90test'
  puts `cat dummyf90testMT.ftk`
  puts `cat dummyf90testMT.f90`
  assert system(@@compileCommand)
 end

 def testIgnoreCommentedTest
  createFtkFile "XbeginTest bob\nendTest"
  Funit::TestSuite.new 'dummyf90test'
  assert_no_match( /Testbob/i, IO.readlines('dummyf90testMT.f90').join )
 end

 def tear_down
  File.rm_f(*Dir["dummyf90test*"])
 end 

end
