! $Id$

subroutine TestFluxFunctions

  use FTK
  use FluxFunctions

  implicit none

  real :: Flux
  real :: Right
  real :: Left

  continue

  FTKSetup

  Right = 0
  Left  = 1

  FTKTestSub CentralFlux( 0.0, 1.0, Flux )

  IsFloatEqual(Flux, 0.5, 0.001)
  IsFloatEqual(Flux, 0.5, 0.00000001)
  IsEqual(Flux, 0.5)
  IsEqual(Flux, 1.0)

  FTKTestSub RoeFlux( 0.0, 1.0, Flux)

  IsFloatEqual(Flux, 0.5, 0.001)
  IsFloatEqual(Flux, 0.5, 0.00000001)
  IsEqual(Flux, 0.5)
  IsEqual(Flux, 1.0)

end subroutine TestFluxFunctions
