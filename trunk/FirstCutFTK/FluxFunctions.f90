! $Id$
module FluxFunctions

  implicit none

  public

contains

  subroutine CentralFlux (LeftState, RightState, InterfaceFlux)

    real, intent(in)  :: LeftState
    real, intent(in)  :: RightState

    real, intent(out) :: InterfaceFlux

    InterfaceFlux = 0.5*(LeftState+RightState)

  end subroutine CentralFlux

  subroutine RoeFlux (LeftState, RightState, InterfaceFlux)

    real, intent(in)  :: LeftState
    real, intent(in)  :: RightState

    real, intent(out) :: InterfaceFlux

    InterfaceFlux = 0.5*(LeftState+RightState)

  end subroutine RoeFlux

end module FluxFunctions
