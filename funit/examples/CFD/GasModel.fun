test_suite GasModel

  real            :: Pressure, Density, Energy

test PerfectPZeroed
  real, parameter :: zero = 0
  call PerfectP (zero, zero, Pressure)
  Assert_Real_Equal( 0, Pressure )
  Assert_Equal_within( 0, Pressure, 0.0000000001 )
end test

test Warbler
end test

test PerfectPKnown
  real :: Density = 1
  Energy  = 1
  call PerfectP( Density, Energy, Pressure )
  Assert_Real_Equal( 0.4, Pressure )
  Assert_True( Pressure > 0 )
  Assert_False( Pressure < 0 )
end test

end test_suite
