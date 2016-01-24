module time_series_data
  implicit none
  integer, parameter :: MAX_POINTS = 100000 ! or use allocate
  type date_time
    integer :: year, month, day, hour, minute
  end type date_time
  type time_series
    type(date_time) :: date_time
    real            :: value      = 0.0
  end type time_series
  type(time_series), dimension(MAX_POINTS), save :: ts_data
contains
  subroutine read_time_series( filename )
    character(len=*), intent(in) :: filename
    integer :: i, ios
    open(10, file=filename, iostat=ios)
    if (ios/=0) then
      print *, 'failed to open file: >>', filename, '<<'
    else
      do i = 1, MAX_POINTS
        read( 10, fmt='(i4,i2,i2,i2,i2,e20.12)', end=20 ) ts_data(i)
      end do
      print *, 'quit reading data after ', MAX_POINTS, ' points'
20    continue
    end if
  end subroutine read_time_series
end module time_series_data
