real :: leftState, rightState, interfaceFlux

beginsetup
  leftState  = 0
  rightState = 1
endsetup

beginTest FluxZero
  real :: state
  state = 0
  IsEqualWithin( 0, Flux(state), 0.00001 )
endTest
 
beginTest FluxOne
  real :: state = 1
  IsEqualWithin( 0.5, Flux(state), 0.00001 )
endTest

beginTest RoeAvgZero
  IsRealEqual( 0, RoeAvg(0.0,0.0) )
  IsFalse( RoeAvg(0.0,0.0)==1 )
endTest

beginTest RoeAvgKnown
  IsRealEqual( 0.5, RoeAvg(leftState,rightState) )
  IsTrue( RoeAvg(leftState,rightState) > 0 )
endTest

beginTest CentralFluxKnown
  call CentralFlux( leftState, rightState, interfaceFlux )
  IsEqualWithin( 0.25, interfaceFlux, 0.001 )
  IsEqualWithin( 0.25, interfaceFlux, 0.00000001 )
  IsEqual( 0.25, interfaceFlux )
endTest

beginTest RoeFluxExpansionShock
  leftState = -1
  call RoeFlux( leftState, rightState, interfaceFlux )
  IsEqual( 0.5, interfaceFlux )
endTest

beginTest RoeFluxZero
  rightState = 0
  call RoeFlux( leftState, rightState, interfaceFlux )
  IsRealEqual( 0, interfaceFlux )
  IsEqual( 0, interfaceFlux )
endTest
