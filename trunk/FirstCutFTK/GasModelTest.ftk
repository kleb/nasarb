! $Id$

subroutine TestSuiteGasModel

  use FortranTK
  use GasModel

  implicit none

  Setup

   real :: Pressure

   real :: Density = 1.0
   real :: Energy  = 1.0

  TestSub PerfectP( Density, Energy, Pressure)

   IsFloatEqual(Pressure, 0.4, 0.0001)
   IsFloatEqual(Pressure, 0.4, 0.000000001)
   IsFloatEqual(Pressure, 0.8, 0.0001)

end subroutine TestSuiteGasModel
