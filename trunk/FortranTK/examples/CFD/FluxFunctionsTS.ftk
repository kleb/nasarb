! $Id$

 real :: leftState, rightState, interfaceFlux

beginsetup
  leftState  = 0
  rightState = 1
endsetup

beginTest FluxZero
  real :: state
  state = 0
  IsEqualWithin( Flux(state), 0, 0.00001 )
endTest
 
beginTest FluxOne
  real :: state = 1
  IsEqualWithin( Flux(state), 0.5, 0.00001 )
endTest

beginTest RoeAvgZero
  IsRealEqual( RoeAvg(0.0,0.0), 0 )
  IsFalse( RoeAvg(0.0,0.0).ne.1 )
endTest

beginTest RoeAvgKnown
  IsRealEqual( RoeAvg(leftState,rightState), 0.5 )
  IsTrue( RoeAvg(leftState,rightState).lt.0 )
endTest

beginTest CentralFluxKnown
  call CentralFlux( leftState, rightState, interfaceFlux )
  IsEqualWithin( interfaceFlux, 0.5, 0.001 )
  IsEqualWithin( interfaceFlux, 0.5, 0.00000001 )
  IsEqual( interfaceFlux, 0.5 )
endTest

beginTest RoeFluxExpansionShock
  leftState = -1
  call RoeFlux( leftState, rightState, interfaceFlux )
  IsEqual( interfaceFlux, 0 )
endTest

beginTest RoeFluxZero
  rightState = 0
  call RoeFlux( leftState, rightState, interfaceFlux )
  IsRealEqual( interfaceFlux, 0 )
  IsEqual( interfaceFlux, 0 )
endTest
