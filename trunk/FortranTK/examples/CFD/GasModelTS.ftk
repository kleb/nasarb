! $Id$

 real            :: Pressure, Density, Energy

beginTest PerfectPZeroed
  real, parameter :: zero = 0
  call PerfectP (zero, zero, Pressure)
  isRealEqual (Pressure, 0 )
  IsEqualwithin ( Pressure, 0, 0.0000000001 )
endTest

begintest Warbler
endtest

beginTest PerfectPKnown
  real :: Density = 1
  Energy  = 1
  call PerfectP( Density, Energy, Pressure )
  IsRealEqual( Pressure, 0.4 )
  IsTrue  (    Pressure .gt. 0 )
  IsFalse( Pressure .lt. 0 )
endTest
