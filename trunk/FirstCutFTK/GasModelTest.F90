! $Id$
#include "FTK.h"

subroutine TestGasModel

  use FTK
  use GasModel

  implicit none

  real :: Pressure
  integer :: Five = 5
  integer :: One = 1

  continue

  call PerfectP( 1.0, 1.0, Pressure)

  IsFloatEqual(Pressure, 0.4, 0.0001)
  IsFloatEqual(Pressure, 0.4, 0.00000001)
  IsFloatEqual(Pressure, 0.8, 0.0001)

! Other assertions:
  IsEqual(One,1.0)
  IsEqual(One,2.0)
  IsTrue(Five.eq.5)
  IsTrue(One+One.eq.3)
  IsFalse(One+One.eq.3)
  IsFalse(Five.eq.5)

end subroutine TestGasModel
