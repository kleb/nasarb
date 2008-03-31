test_suite StopWatch

integer, dimension(8) :: dateAndTime1, dateAndTime2
real :: seconds

setup
  NotInitialized = .TRUE.
  last    = 0
  seconds = HUGE(0.0)
end setup

test SystemDateAndTimeWorks
 call date_and_time(values=dateAndTime1)
 Assert_True( dateAndTime1(1) /= -huge(0) )
 Assert_True( size(dateAndTime1,1) == 8 )
end test

! test secBetween
test OneMSecDifference
  dateAndTime1 = (/ 2000, 1, 1, 0, 0, 0, 0, 0 /)
  dateAndTime2 = (/ 2000, 1, 1, 0, 0, 0, 0, 1 /)
  seconds = SecBetween(dateAndTime1, dateAndTime2)
  Assert_Real_Equal( 0.001, seconds)
end test

test MinuteRollover
  dateAndTime1 = (/ 2000, 1, 1, 0, 0, 0,59, 0 /)
  dateAndTime2 = (/ 2000, 1, 1, 0, 0, 1, 0, 0 /)
  seconds = SecBetween(dateAndTime1, dateAndTime2)
  Assert_Real_Equal( 1.0, seconds )
end test

! test secSinceLast
test InitializationState
  Assert_True(notInitialized)
  seconds = secSinceLast()
  Assert_False(notInitialized)
  seconds = secSinceLast()
  Assert_False(notInitialized)
end test

test InitiallyReturnsZero
  seconds = secSinceLast()
  Assert_Real_Equal( 0.0, seconds )
  call timeDelay(seconds)
  seconds = secSinceLast()
  Assert_True( seconds /= 0.0 )
end test

subroutine timeDelay (sum)
  integer :: i
  real    :: sum
  do i = 1, 1000000
   sum = sum + i
  enddo
end subroutine timeDelay

test ComputesSeconds
  seconds = secSinceLast()
  call timeDelay (seconds)
  seconds = secSinceLast()
  Assert_True( seconds > 0.0 )
end test

test ComputesSecondsSpecial
  real :: expectedSeconds

  seconds = secSinceLast()
  dateAndTime1 = last
  call timeDelay (seconds)
  seconds = secSinceLast()
  dateAndTime2 = last
  expectedSeconds = secBetween(dateAndTime1,dateAndTime2)
  Assert_Real_Equal( expectedSeconds, seconds )
end test

end test_suite
