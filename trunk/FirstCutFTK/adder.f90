! $Id$
module adder

implicit none

public

contains

  subroutine add (a, b, c)

    integer a,b,c

    print *, "I was called (adder)"

  end subroutine add

end module
