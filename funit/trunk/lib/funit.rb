
require 'funit/compiler'
require 'funit/functions'
require 'funit/assertions'
require 'funit/testsuite'

require 'rubygems'
require 'f90_mkdeps'

module Funit

  VERSION = '0.1.3'

  ##
  # run all tests

  def run_tests
    Compiler.new# a test for compiler env set (FIXME: remove this later)
    write_test_runner( test_suites = parse_command_line )
    test_suites.each{ |test_suite| TestSuite.new test_suite }
    compile_tests test_suites
    raise "TestRunner failed to execute." unless system './TestRunner'
  end

end

#--
# Copyright 2006-2007 United States Government as represented by
# NASA Langley Research Center. No copyright is claimed in
# the United States under Title 17, U.S. Code. All Other Rights
# Reserved.
#
# This file is governed by the NASA Open Source Agreement.
# See License.txt for details.
#++
