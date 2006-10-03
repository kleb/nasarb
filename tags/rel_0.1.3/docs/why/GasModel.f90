! $Id$
module GasModel

! use Gammas  !! not handled yet

  implicit none

  real, parameter   :: Gamma = 1.4

contains

  subroutine PerfectP (Density, Energy, Pressure)
    real, intent(in)  :: Density 
    real, intent(in)  :: Energy
    real, intent(out) :: Pressure
    Pressure = Density * Energy * ( Gamma - 1.0 )
  end subroutine PerfectP

end module GasModel
