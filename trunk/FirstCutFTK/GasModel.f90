! $Id$
module GasModel

  implicit none

  public

contains

  subroutine PerfectP (Density, Energy, Pressure)

    real, parameter :: Gamma = 1.4

    real, intent(in)  :: Density 
    real, intent(in)  :: Energy

    real, intent(out) :: Pressure

    Pressure = Density * Energy * ( Gamma - 1.0 )

    print *, "PerfectP subroutine was called:"
    print *, "   Gamma: ", Gamma
    print *, " Density: ", Density
    print *, "  Energy: ", Energy
    print *, "Pressure: ", Pressure

  end subroutine PerfectP

end module GasModel
