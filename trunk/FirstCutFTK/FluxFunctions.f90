! $Id$
module FluxFunctions

  implicit none

contains

  subroutine CentralFlux( LeftState, RightState, InterfaceFlux )
    real, intent(in)  :: leftState
    real, intent(in)  :: rightState
    real, intent(out) :: interfaceFlux
    interfaceFlux = 0.5*(Flux(leftState)+Flux(rightState))
  end subroutine CentralFlux

  subroutine RoeFlux( LeftState, RightState, InterfaceFlux )
    real, intent(in)  :: leftState
    real, intent(in)  :: rightState
    real, intent(out) :: interfaceFlux
    interfaceFlux = 0.5*(Flux(leftState)+Flux(rightState)) &
                  - 0.5*RoeAvg(leftState,rightState)*(rightState-leftState)
  end subroutine RoeFlux

  real function Flux( state )
    real, intent(in) :: state
    Flux = 0.5*state**2
  end function Flux

  real function RoeAvg( leftState, rightState )
    real, intent(in) :: leftState, rightState
    RoeAvg = 0.5*(leftState+rightState)
  end function RoeAvg

end module FluxFunctions
