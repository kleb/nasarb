real            :: Pressure, Density, Energy

beginTest PerfectPZeroed
  real, parameter :: zero = 0
  call PerfectP (zero, zero, Pressure)
  isRealEqual ( 0, Pressure )
  IsEqualwithin ( 0, Pressure, 0.0000000001 )
endTest

begintest Warbler
endtest

beginTest PerfectPKnown
  real :: Density = 1
  Energy  = 1
  call PerfectP( Density, Energy, Pressure )
  IsRealEqual( 0.4, Pressure )
  IsTrue  ( Pressure > 0 )
  IsFalse( Pressure < 0 )
endTest
