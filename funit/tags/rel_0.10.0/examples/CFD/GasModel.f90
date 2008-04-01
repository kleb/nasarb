module GasModel

 use Gammas

  implicit none

contains

  subroutine PerfectP (Density, Energy, Pressure)
    real, intent(in)  :: Density 
    real, intent(in)  :: Energy
    real, intent(out) :: Pressure
    Pressure = Density * Energy * ( Gamma - 1.0 )
  end subroutine PerfectP

end module GasModel
