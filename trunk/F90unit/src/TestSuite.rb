require 'Asserts'

class TestSuite < File

 include Asserts

 def initialize suiteName

  @suiteName = suiteName
  File.delete(suiteName+"TS.f90") if File.exists?(suiteName+"TS.f90")
  super(suiteName+"TS.f90","w")
  @tests, @setup, @teardown = [], [], []

  puts <<-TOP
! #{@suiteName}TS.f90 - a Fortran mobility test suite for #{@suiteName}.f90
!
! [dynamically generated from #{@suiteName}TS.ftk
!  by #{File.basename $0} Ruby script #{Time.now}]

module #{@suiteName}TS

 use #{@suiteName}

 implicit none

 private

 public :: TS#{@suiteName}

 logical :: noAssertFailed

 integer :: numTests          = 0
 integer :: numAsserts        = 0
 integer :: numAssertsTested  = 0
 integer :: numFailures       = 0

  TOP
 end

 def addtoSetup ftkFile
  @setup.push($_) until ftkFile.gets=~/endSetup/i
 end

 def addtoTeardown ftkFile
  @teardown.push($_) until ftkFile.gets=~/endTeardown/i
 end

 def aTest testName, testSuite, ftkFile
  @testName, @testSuite = testName, testSuite
  @tests.push(testName)
  syntaxError("test name #@testName not unique",@testSuite) if (@tests.uniq!)

  puts " subroutine Test#{testName}\n\n"

  numOfAsserts = 0
  until ftkFile.gets=~/endTest/i
   case $_
   when $commentLine
    puts $_
   when /Is(RealEqual|False|True|EqualWithin|Equal)/i
    numOfAsserts += 1
    send $&.downcase!, $_
   else
    puts $_
   end
  end
  warning("no asserts in test", testSuite) if numOfAsserts == 0

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

 subroutine TS#{@suiteName}( nTests, nAsserts, nAssertsTested, nFailures )

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

 end subroutine TS#{@suiteName}

end module #{@suiteName}TS
  LASTONE
  super
  File.chmod(0444,@suiteName+"TS.f90")
 end

end
