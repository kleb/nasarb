require 'Asserts'

class TestSuite < File

 include Asserts

 def initialize suiteName

  @suiteName = suiteName
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

 def addtoSetup
  @setup.push($_) until $stdin.gets=~/endSetup/
 end

 def addtoTeardown
  @teardown.push($_) until $stdin.gets=~/endTeardown/
 end

 def aTest testName, testSuite
  @testName, @testSuite = testName, testSuite
  @tests.push(testName)
  puts " subroutine Test#{testName}\n\n"

  numOfAsserts = 0
  until $stdin.gets=~/endTest/
   if /Is\w+/
    numOfAsserts += 1
    send $&, $_
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
 end

end
