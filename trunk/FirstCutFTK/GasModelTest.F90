! $Id$
#include "FTK.h"

subroutine TestGasModel

  use FTK
  use GasModel

  implicit none

  real :: Pressure

  continue

  call PerfectP( 1.0, 1.0, Pressure)

  IsFloatEqual(Pressure, 0.4, 0.0001)
  IsFloatEqual(Pressure, 0.4, 0.00000001)
  IsFloatEqual(Pressure, 0.8, 0.0001)

end subroutine TestGasModel
