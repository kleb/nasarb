integer, dimension(8) :: dateAndTime1, dateAndTime2
real :: seconds

beginSetup
  NotInitialized = .TRUE.
  last    = 0
  seconds = HUGE(0.0)
endSetup

beginTest SystemDateAndTimeWorks
 call date_and_time(values=dateAndTime1)
 IsTrue( dateAndTime1(1) /= -huge(0) )
 IsTrue( size(dateAndTime1,1) == 8 )
endTest

! test secBetween
beginTest OneMSecDifference
  dateAndTime1 = (/ 2000, 1, 1, 0, 0, 0, 0, 0 /)
  dateAndTime2 = (/ 2000, 1, 1, 0, 0, 0, 0, 1 /)
  seconds = SecBetween(dateAndTime1, dateAndTime2)
  IsRealEqual(seconds, 0.001)
endTest

beginTest MinuteRollover
  dateAndTime1 = (/ 2000, 1, 1, 0, 0, 0,59, 0 /)
  dateAndTime2 = (/ 2000, 1, 1, 0, 0, 1, 0, 0 /)
  seconds = SecBetween(dateAndTime1, dateAndTime2)
  IsRealEqual(seconds, 1.0)
endTest

! test secSinceLast
beginTest InitializationState
  IsTrue(notInitialized)
  seconds = secSinceLast()
  IsFalse(notInitialized)
  seconds = secSinceLast()
  IsFalse(notInitialized)
endTest

beginTest InitiallyReturnsZero
  seconds = secSinceLast()
  IsRealEqual(seconds, 0.0)
  call timeDelay(seconds)
  seconds = secSinceLast()
  IsTrue( seconds /= 0.0 )
endTest

subroutine timeDelay (sum)
  integer :: i
  real    :: sum
  do i = 1, 1000000
   sum = sum + i
  enddo
end subroutine timeDelay

beginTest ComputesSeconds
  seconds = secSinceLast()
  call timeDelay (seconds)
  seconds = secSinceLast()
  IsTrue( seconds > 0.0 )
endTest

beginTest ComputesSecondsSpecial
  real :: expectedSeconds

  seconds = secSinceLast()
  dateAndTime1 = last
  call timeDelay (seconds)
  seconds = secSinceLast()
  dateAndTime2 = last
  expectedSeconds = secBetween(dateAndTime1,dateAndTime2)
  IsRealEqual(seconds, expectedSeconds)
endTest
