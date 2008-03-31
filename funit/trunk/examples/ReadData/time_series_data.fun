test_suite time_series_data

  character(len=10), parameter :: FILE = 'values.txt'

setup
  open(8, file=FILE)
    write(8,'(a)'), '200609300000 0.223200546265E+003'
    write(8,'(a)'), '200609300132 0.226001495361E+003'
  close(8)
end setup

test load_time_series_data_from_file
  call read_time_series( FILE )
  Assert_Equal(         2006, ts_data(1)%date_time%year )
  Assert_Equal(            9, ts_data(1)%date_time%month )
  Assert_Equal(           30, ts_data(1)%date_time%day )
  Assert_Equal(            0, ts_data(1)%date_time%hour )
  Assert_Equal(            0, ts_data(1)%date_time%minute )
  Assert_Equal_Within( 223.2, ts_data(1)%value, 0.1 )
  Assert_Equal(         2006, ts_data(2)%date_time%year )
  Assert_Equal(            9, ts_data(2)%date_time%month )
  Assert_Equal(           30, ts_data(2)%date_time%day )
  Assert_Equal(            1, ts_data(2)%date_time%hour )
  Assert_Equal(           32, ts_data(2)%date_time%minute )
  Assert_Equal_Within( 226.0, ts_data(2)%value, 0.1 )
end test

teardown
  call system('/bin/rm '//FILE)
end teardown

end test_suite

