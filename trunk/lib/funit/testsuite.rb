# Create testsuite wrapper code

require 'funit/assertions'
require 'funit/functions'
require 'ftools'

module Funit

  include Assertions

  class TestSuite < File

    include Funit# ?!

    def initialize suiteName
      @lineNumber = 'blank'
      @suiteName = suiteName
      return nil unless funit_exists?(suiteName)
      File.delete(suiteName+"_fun.f90") if File.exists?(suiteName+"_fun.f90")
      super(suiteName+"_fun.f90","w")
      @tests, @setup, @teardown = [], [], []
      topWrapper
      expand
      close
    end

    def topWrapper
      puts <<-TOP
! #{@suiteName}_fun.f90 - a unit test suite for #{@suiteName}.f90
!
! #{File.basename $0} generated this file from #{@suiteName}.fun
! at #{Time.now}

module #{@suiteName}_fun

 use #{@suiteName}

 implicit none

 logical :: noAssertFailed

 public :: test_#@suiteName

 private

 integer :: numTests          = 0
 integer :: numAsserts        = 0
 integer :: numAssertsTested  = 0
 integer :: numFailures       = 0

      TOP
    end

    def expand
      funit_file = @suiteName+".fun"
      $stderr.print "expanding #{funit_file}..."
   
      funit_contents = IO.readlines(funit_file)
      @funit_TotalLines = funit_contents.length

      while (line = funit_contents.shift) && line !~ $keyword
        puts line
      end

      funit_contents.unshift line

      puts " contains\n\n"

      while (line = funit_contents.shift)
        case line
        when $commentLine
          puts line
        when /beginSetup/i
          addtoSetup funit_contents
        when /beginTeardown/i
          addtoTeardown funit_contents
        when /XbeginTest\s+(\w+)/i
          ignoreTest($1,funit_contents)
        when /beginTest\s+(\w+)/i
          aTest($1,funit_contents)
        when /beginTest/i
          syntaxError "no name given for beginTest", @suiteName
        when /end(Setup|Teardown|Test)/i
          syntaxError "no matching begin#$1 for an #$&", @suiteName
        when ASSERTION_PATTERN
          syntaxError "#$1 assert not in a test block", @suiteName
        else
          puts line
        end
      end # while

      $stderr.puts "done."

    end

    def addtoSetup funit_contents
      while (line = funit_contents.shift) && line !~ /endSetup/i
        @setup.push line
      end
    end

    def addtoTeardown funit_contents
      while (line = funit_contents.shift) && line !~ /endTeardown/i
        @teardown.push line
      end
    end

    def ignoreTest testName, funit_contents
      warning("Ignoring test: #{testName}", @suiteName)
      line = funit_contents.shift while line !~ /endTest/i
    end

    def aTest testName, funit_contents
      @testName = testName
      @tests.push testName
      syntaxError("test name #@testName not unique",@suiteName) if (@tests.uniq!)

      puts " subroutine #{testName}\n\n"

      numOfAsserts = 0
  
      while (line = funit_contents.shift) && line !~ /endTest/i
        case line
        when $commentLine
          puts line
        when /Is(RealEqual|False|True|EqualWithin|Equal)/i
          @lineNumber = @funit_TotalLines - funit_contents.length
          numOfAsserts += 1
          puts send( $&.downcase!, line )
        else
          puts line
        end
      end
      warning("no asserts in test", @suiteName) if numOfAsserts == 0

      puts "\n  numTests = numTests + 1\n\n"
      puts " end subroutine #{testName}\n\n"
    end

    def close
      puts "\n subroutine Setup"
      puts @setup
      puts "  noAssertFailed = .true."
      puts " end subroutine Setup\n\n"

      puts "\n subroutine Teardown"
      puts @teardown
      puts " end subroutine Teardown\n\n"

      puts <<-NEXTONE

 subroutine test_#{@suiteName}( nTests, nAsserts, nAssertsTested, nFailures )

  integer :: nTests
  integer :: nAsserts
  integer :: nAssertsTested
  integer :: nFailures

  continue
      NEXTONE

      @tests.each do |testName|
        puts "\n  call Setup"
        puts "  call #{testName}"
        puts "  call Teardown"
      end

      puts <<-LASTONE

  nTests          = numTests
  nAsserts        = numAsserts
  nAssertsTested  = numAssertsTested
  nFailures       = numFailures

 end subroutine test_#{@suiteName}

end module #{@suiteName}_fun
      LASTONE
      super
    end

  end

end

#--
# Copyright 2006 United States Government as represented by
# NASA Langley Research Center. No copyright is claimed in
# the United States under Title 17, U.S. Code. All Other Rights
# Reserved.
#
# This file is governed by the NASA Open Source Agreement.
# See License.txt for details.
#++