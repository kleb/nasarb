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

    print *, "CentralFlux subroutine was called:"
    print *, "    LeftState: ", LeftState
    print *, "   RightState: ", RightState
    print *, "InterfaceFlux: ", InterfaceFlux

  end subroutine CentralFlux

end module FluxFunctions
