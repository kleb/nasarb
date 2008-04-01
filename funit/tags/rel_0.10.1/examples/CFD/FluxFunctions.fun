test_suite FluxFunctions

real :: leftState, rightState, interfaceFlux

setup
  leftState  = 0
  rightState = 1
end setup

test FluxZero
  real :: state
  state = 0
  Assert_Equal_Within( 0, Flux(state), 0.00001 )
end test
 
test FluxOne
  real :: state = 1
  Assert_Equal_Within( 0.5, Flux(state), 0.00001 )
end test

test RoeAvgZero
  Assert_Real_Equal( 0, RoeAvg(0.0,0.0) )
  Assert_False( RoeAvg(0.0,0.0)==1 )
end test

test RoeAvgKnown
  Assert_Real_Equal( 0.5, RoeAvg(leftState,rightState) )
  Assert_True( RoeAvg(leftState,rightState) > 0 )
end test

test CentralFluxKnown
  call CentralFlux( leftState, rightState, interfaceFlux )
  Assert_Equal_Within( 0.25, interfaceFlux, 0.001 )
  Assert_Equal_Within( 0.25, interfaceFlux, 0.00000001 )
  Assert_Equal( 0.25, interfaceFlux )
end test

test RoeFluxExpansionShock
  leftState = -1
  call RoeFlux( leftState, rightState, interfaceFlux )
  Assert_Equal( 0.5, interfaceFlux )
end test

test RoeFluxZero
  rightState = 0
  call RoeFlux( leftState, rightState, interfaceFlux )
  Assert_Real_Equal( 0, interfaceFlux )
  Assert_Equal( 0, interfaceFlux )
end test

end test_suite
