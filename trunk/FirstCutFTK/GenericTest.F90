! $Id$

subroutine TestSuiteGeneric

  use FortranTK

  implicit none

  Setup

   integer :: Five = 5
   integer :: One = 1

   IsFloatEqual(One,1.0,0.000001)
   IsFloatEqual(One,1.0,0.00000000001)
   IsEqual(One,1.0)
   IsEqual(One,2.0)
   IsTrue(Five.eq.5)
   IsTrue(One+One.eq.3)
   IsFalse(One+One.eq.3)
   IsFalse(Five.eq.5)

end subroutine TestSuiteGeneric
