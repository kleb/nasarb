module Funit

  include Funit::Assertions

  class TestSuite < File

    include Funit

    def initialize suiteName
      @lineNumber = 'blank'
      @suiteName = suiteName
      return nil unless ftkExists?(suiteName)
      File.delete(suiteName+"MT.f90") if File.exists?(suiteName+"MT.f90")
      super(suiteName+"MT.f90","w")
      @tests, @setup, @teardown = Array.new, Array.new, Array.new
      topWrapper
      expand
      close
    end

    def topWrapper
      puts <<-TOP
! #{@suiteName}MT.f90 - a Fortran mobility test suite for #{@suiteName}.f90
!
! [dynamically generated from #{@suiteName}MT.ftk
!  by #{File.basename $0} Ruby script #{Time.now}]

module #{@suiteName}MT

 use #{@suiteName}

 implicit none

 private

 public :: MT#{@suiteName}

 logical :: noAssertFailed

 integer :: numTests          = 0
 integer :: numAsserts        = 0
 integer :: numAssertsTested  = 0
 integer :: numFailures       = 0

      TOP
    end

    def expand
 
      ftkFile = @suiteName+"MT.ftk"
      $stderr.puts "parsing #{ftkFile}"
   
      ftk = IO.readlines(ftkFile)
      @ftkTotalLines = ftk.length

      while (line = ftk.shift) && line !~ $keyword
        puts line
      end

      ftk.unshift line

      puts " contains\n\n"

      while (line = ftk.shift)
        case line
        when $commentLine
          puts line
        when /beginSetup/i
          addtoSetup ftk
        when /beginTeardown/i
          addtoTeardown ftk
        when /XbeginTest\s+(\w+)/i
          ignoreTest($1,ftk)
        when /beginTest\s+(\w+)/i
          aTest($1,ftk)
        when /beginTest/i
          syntaxError "no name given for beginTest", @suiteName
        when /end(Setup|Teardown|Test)/i
          syntaxError "no matching begin#$1 for an #$&", @suiteName
        when $assertRegEx
          syntaxError "#$1 assert not in a test block", @suiteName
        else
          puts line
        end
      end # while

      $stderr.puts "completed #{ftkFile}"

    end

    def addtoSetup ftk
      while (line = ftk.shift) && line !~ /endSetup/i
        @setup.push line
      end
    end

    def addtoTeardown ftk
      while (line = ftk.shift) && line !~ /endTeardown/i
        @teardown.push line
      end
    end

    def ignoreTest testName, ftk
      warning("Ignoring test: #{testName}", @suiteName)
      line = ftk.shift while line !~ /endTest/i
    end

    def aTest testName, ftk
      @testName = testName
      @tests.push testName
      syntaxError("test name #@testName not unique",@suiteName) if (@tests.uniq!)

      puts " subroutine Test#{testName}\n\n"

      numOfAsserts = 0
  
      while (line = ftk.shift) && line !~ /endTest/i
        case line
        when $commentLine
          puts line
        when /Is(RealEqual|False|True|EqualWithin|Equal)/i
          @lineNumber = @ftkTotalLines - ftk.length
          numOfAsserts += 1
          puts send( $&.downcase!, line )
        else
          puts line
        end
      end
      warning("no asserts in test", @suiteName) if numOfAsserts == 0

      puts "\n  numTests = numTests + 1\n\n"
      puts " end subroutine Test#{testName}\n\n"
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

 subroutine MT#{@suiteName}( nTests, nAsserts, nAssertsTested, nFailures )

  integer :: nTests
  integer :: nAsserts
  integer :: nAssertsTested
  integer :: nFailures

  continue
      NEXTONE

      @tests.each do |testName|
        puts "\n  call Setup"
        puts "  call Test#{testName}"
        puts "  call Teardown"
      end

      puts <<-LASTONE

  nTests          = numTests
  nAsserts        = numAsserts
  nAssertsTested  = numAssertsTested
  nFailures       = numFailures

 end subroutine MT#{@suiteName}

end module #{@suiteName}MT
      LASTONE
      super
      File.chmod(0444,@suiteName+"MT.f90")
    end

  end # class TestSuite

end # module Funit
