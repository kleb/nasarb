character(len=*), parameter :: FILE = 'values.txt'

beginSetup
  open(8, file=FILE)
    write(8,'(a)'), '200609300000 0.223200546265E+003'
    write(8,'(a)'), '200609300132 0.226001495361E+003'
  close(8)
endSetup

beginTest load_time_series_data_from_file
  call read_time_series( FILE )
  IsEqual(        2006, ts_data(1)%date_time%year )
  IsEqual(           9, ts_data(1)%date_time%month )
  IsEqual(          30, ts_data(1)%date_time%day )
  IsEqual(           0, ts_data(1)%date_time%hour )
  IsEqual(           0, ts_data(1)%date_time%minute )
  IsEqualWithin( 223.2, ts_data(1)%value, 0.1 )
  IsEqual(        2006, ts_data(2)%date_time%year )
  IsEqual(           9, ts_data(2)%date_time%month )
  IsEqual(          30, ts_data(2)%date_time%day )
  IsEqual(           1, ts_data(2)%date_time%hour )
  IsEqual(          32, ts_data(2)%date_time%minute )
  IsEqualWithin( 226.0, ts_data(2)%value, 0.1 )
endTest

beginTeardown
  call system('rm '//FILE)
endTeardown
