require 'funit/functions'
require 'funit/assertions'
require 'funit/test_suite'

def runAllFtks

 Compiler.new # a test for compiler env set (remove this later)

 writeTestRunner(testSuites = parseCommandLine)

 # convert each *MT.ftk file into a pure Fortran9x file:

 threads = Array.new

 testSuites.each do |testSuite|
  threads << Thread.new(testSuite) do |testSuite|
   testSuiteF90 = TestSuite.new(testSuite)
  end
 end
 
 threads.each{ |thread| thread.join }
 
 compileTests testSuites

 raise "Failed to execute TestRunner" unless system("./TestRunner")
 
end
