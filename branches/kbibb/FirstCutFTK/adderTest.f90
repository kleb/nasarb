! $Id$
#include "testKit.inc"
subroutine TestAdd

  use testKit

  use adder

  integer :: wrongAnswer

  call add (0,1,wrongAnswer)
  istrue((wrongAnswer == 5))

  print*, testKitHasFailed

end subroutine TestAdd
