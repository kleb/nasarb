require 'funit/functions'
require 'funit/fortran_deps'
require 'funit/assertions'
require 'funit/test_suite'

module Funit
  def runAllFtks
    Compiler.new # a test for compiler env set (remove this later)
    writeTestRunner(testSuites = parseCommandLine)

    # convert each *MT.ftk file into a pure Fortran9x file:
    testSuites.each do |testSuite|
      testSuiteF90 = TestSuite.new(testSuite)
    end
 
    compileTests testSuites

    raise "Failed to execute TestRunner" unless system("./TestRunner")
  end
end
