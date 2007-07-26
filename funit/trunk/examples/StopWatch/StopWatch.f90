module StopWatch

  implicit none

  public

  logical :: notInitialized = .TRUE.

  integer, dimension(8) :: last

  contains

  real function SecBetween(beginDnT, endDnT)
    integer, dimension(8), intent(in)  :: beginDnT, endDnT
    real :: days, hours, minutes, seconds
    integer, parameter :: yr=1, mo=2, day=3, utc=4, hr=5, mn=6, s=7, ms=8
    
    continue

    if ( endDnT(day) == beginDnT(day) ) then
       days = 0
    else
       days = 1 ! note: assuming one day
    endif

    hours   = endDnT(hr) - beginDnT(hr) + 24*days
    minutes = endDnT(mn) - beginDnT(mn) + 60*hours
    seconds = endDnT(s)  - beginDnT(s)  + 60*minutes

    SecBetween = seconds + ( endDnT(ms) - beginDnT(ms) ) / 1000.

  end function SecBetween
    
  real function secSinceLast()

    integer, dimension(8) :: now

    if (notInitialized) then
      notInitialized = .FALSE.
      secSinceLast = 0.0
      call date_and_time(values=last)
    else
      call date_and_time(values=now)
      secSinceLast = secBetween(last, now)
      last = now
    endif

  end function secSinceLast

end module StopWatch
