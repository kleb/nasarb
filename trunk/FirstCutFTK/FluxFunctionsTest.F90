! $Id$

subroutine TestFluxFunctions

  use FTK
  use FluxFunctions

  implicit none

  real :: Flux

  continue

  call CentralFlux( 0.0, 1.0, Flux)

  IsFloatEqual(Flux, 0.5, 0.001)
  IsFloatEqual(Flux, 0.5, 0.00000001)
  IsEqual(Flux, 0.5)
  IsEqual(Flux, 1.0)

end subroutine TestFluxFunctions
