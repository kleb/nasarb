module StopWatch

  implicit none

  public

  logical :: NotInitialized = .TRUE.

  integer, dimension(8) :: initial, last

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
    
end module StopWatch
