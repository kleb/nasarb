! $Id$

subroutine TestSuiteFluxFunctions

  use FortranTK
  use FluxFunctions

  implicit none

  Setup

   real :: Flux

   real :: rightState = 0
   real :: leftState  = 1

  TestSub CentralFlux( leftState, rightState, Flux )

   IsFloatEqual(Flux, 0.5, 0.001)
   IsFloatEqual(Flux, 0.5, 0.00000001)
   IsEqual(Flux, 0.5)
   IsEqual(Flux, 1.0)

  TestSub RoeFlux( leftState, rightState, Flux)

!  real :: rightState = 0.5

   IsFloatEqual(Flux, 0.25, 0.001)
   IsFloatEqual(Flux, 0.25, 0.00000001)
   IsEqual(Flux, 0.25)
   IsEqual(Flux, 0)

end subroutine TestSuiteFluxFunctions
