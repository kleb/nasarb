# Define a method to find and run all tests
#--
# Copyright 2006 United States Government as represented by
# NASA Langley Research Center. No copyright is claimed in
# the United States under Title 17, U.S. Code. All Other Rights
# Reserved.
#
# This file is governed by the NASA Open Source Agreement.
# See COPYING for details.
#++

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
