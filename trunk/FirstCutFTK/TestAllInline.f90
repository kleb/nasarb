! $Id$
!not the preferred way...
program testAll

  implicit none

  call TestAdd

end program testALL

  subroutine TestAdd

    use adder

    call add (0,1,2)

  end subroutine TestAdd
