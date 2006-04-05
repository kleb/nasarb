! FluxFunctionsTS.f90 - a Fortran mobility test suite for FluxFunctions.f90
!
! [dynamically generated from FluxFunctionsTS.ftk
!  by FTKtest Ruby script Wed Nov 07 07:53:00 EST 2001]

module FluxFunctionsTS

 use FluxFunctions

 implicit none

 private

 public :: TSFluxFunctions

 logical :: noAssertFailed

 integer :: numTests          = 0
 integer :: numAsserts        = 0
 integer :: numAssertsTested  = 0
 integer :: numFailures       = 0

! $Id$

 real :: leftState, rightState, interfaceFlux

 contains


 subroutine TestFluxZero

  real :: state
  state = 0

  ! IsEqualWithin assertion
  numAsserts = numAsserts + 1
  if (noAssertFailed) then
   if (.not.( 0+ 0.00001 .ge. Flux(state) &
             .and. 0- 0.00001 .le. Flux(state))) then
    print *, " FAILURE: IsEqualWithin in test FluxZero, &
                       &line 13 of FluxFunctionsTS.ftk"
    print *, "   ", " Flux(state) is not", 0,"within", 0.00001 
    noAssertFailed = .false.
    numFailures    = numFailures + 1
   else
    numAssertsTested = numAssertsTested + 1
   endif
  endif

  numTests = numTests + 1

 end subroutine TestFluxZero

 
 subroutine TestFluxOne

  real :: state = 1

  ! IsEqualWithin assertion
  numAsserts = numAsserts + 1
  if (noAssertFailed) then
   if (.not.( 0.5+ 0.00001 .ge. Flux(state) &
             .and. 0.5- 0.00001 .le. Flux(state))) then
    print *, " FAILURE: IsEqualWithin in test FluxOne, &
                       &line 18 of FluxFunctionsTS.ftk"
    print *, "   ", " Flux(state) is not", 0.5,"within", 0.00001 
    noAssertFailed = .false.
    numFailures    = numFailures + 1
   else
    numAssertsTested = numAssertsTested + 1
   endif
  endif

  numTests = numTests + 1

 end subroutine TestFluxOne


 subroutine TestRoeAvgZero


  ! IsRealEqual assertion
  numAsserts = numAsserts + 1
  if (noAssertFailed) then
   if (.not.( 0 +2*spacing(real( 0 )).ge. RoeAvg(0.0,0.0) &
             .and. 0 -2*spacing(real( 0 )).le. RoeAvg(0.0,0.0))) then
    print *, " FAILURE: IsRealEqual in test RoeAvgZero, &
                       &line 22 of FluxFunctionsTS.ftk"
    print *, "   ", " RoeAvg(0.0,0.0) is not", 0 ,"within",2*spacing(real( 0 ))
    noAssertFailed = .false.
    numFailures    = numFailures + 1
   else
    numAssertsTested = numAssertsTested + 1
   endif
  endif

  ! IsFalse assertion
  numAsserts = numAsserts + 1
  if (noAssertFailed) then
   if ( RoeAvg(0.0,0.0).ne.1 ) then
    print *, " FAILURE: IsFalse in test RoeAvgZero, &
                       &line 23 of FluxFunctionsTS.ftk"
    print *, "   ", " RoeAvg(0.0,0.0).ne.1  is not false"
    noAssertFailed = .false.
    numFailures    = numFailures + 1
   else
    numAssertsTested = numAssertsTested + 1
   endif
  endif

  numTests = numTests + 1

 end subroutine TestRoeAvgZero


 subroutine TestRoeAvgKnown


  ! IsRealEqual assertion
  numAsserts = numAsserts + 1
  if (noAssertFailed) then
   if (.not.( 0.5 +2*spacing(real( 0.5 )).ge. RoeAvg(leftState,rightState) &
             .and. 0.5 -2*spacing(real( 0.5 )).le. RoeAvg(leftState,rightState))) then
    print *, " FAILURE: IsRealEqual in test RoeAvgKnown, &
                       &line 27 of FluxFunctionsTS.ftk"
    print *, "   ", " RoeAvg(leftState,rightState) is not", 0.5 ,"within",2*spacing(real( 0.5 ))
    noAssertFailed = .false.
    numFailures    = numFailures + 1
   else
    numAssertsTested = numAssertsTested + 1
   endif
  endif

  ! IsTrue assertion
  numAsserts = numAsserts + 1
  if (noAssertFailed) then
   if (.not.( RoeAvg(leftState,rightState).lt.0 )) then
    print *, " FAILURE: IsTrue in test RoeAvgKnown, &
                       &line 28 of FluxFunctionsTS.ftk"
    print *, "   ", " RoeAvg(leftState,rightState).lt.0  is not true"
    noAssertFailed = .false.
    numFailures    = numFailures + 1
   else
    numAssertsTested = numAssertsTested + 1
   endif
  endif

  numTests = numTests + 1

 end subroutine TestRoeAvgKnown


 subroutine TestCentralFluxKnown

  call CentralFlux( leftState, rightState, interfaceFlux )

  ! IsEqualWithin assertion
  numAsserts = numAsserts + 1
  if (noAssertFailed) then
   if (.not.( 0.5+ 0.001 .ge. interfaceFlux &
             .and. 0.5- 0.001 .le. interfaceFlux)) then
    print *, " FAILURE: IsEqualWithin in test CentralFluxKnown, &
                       &line 33 of FluxFunctionsTS.ftk"
    print *, "   ", " interfaceFlux is not", 0.5,"within", 0.001 
    noAssertFailed = .false.
    numFailures    = numFailures + 1
   else
    numAssertsTested = numAssertsTested + 1
   endif
  endif

  ! IsEqualWithin assertion
  numAsserts = numAsserts + 1
  if (noAssertFailed) then
   if (.not.( 0.5+ 0.00000001 .ge. interfaceFlux &
             .and. 0.5- 0.00000001 .le. interfaceFlux)) then
    print *, " FAILURE: IsEqualWithin in test CentralFluxKnown, &
                       &line 34 of FluxFunctionsTS.ftk"
    print *, "   ", " interfaceFlux is not", 0.5,"within", 0.00000001 
    noAssertFailed = .false.
    numFailures    = numFailures + 1
   else
    numAssertsTested = numAssertsTested + 1
   endif
  endif

  ! IsEqual assertion
  numAsserts = numAsserts + 1
  if (noAssertFailed) then
   if (.not.( interfaceFlux== 0.5 )) then
    print *, " FAILURE: IsEqual in test CentralFluxKnown, &
                       &line 35 of FluxFunctionsTS.ftk"
    print *, "   ", " interfaceFlux is not",  0.5 
    noAssertFailed = .false.
    numFailures    = numFailures + 1
   else
    numAssertsTested = numAssertsTested + 1
   endif
  endif

  numTests = numTests + 1

 end subroutine TestCentralFluxKnown


 subroutine TestRoeFluxExpansionShock

  leftState = -1
  call RoeFlux( leftState, rightState, interfaceFlux )

  ! IsEqual assertion
  numAsserts = numAsserts + 1
  if (noAssertFailed) then
   if (.not.( interfaceFlux== 0 )) then
    print *, " FAILURE: IsEqual in test RoeFluxExpansionShock, &
                       &line 41 of FluxFunctionsTS.ftk"
    print *, "   ", " interfaceFlux is not",  0 
    noAssertFailed = .false.
    numFailures    = numFailures + 1
   else
    numAssertsTested = numAssertsTested + 1
   endif
  endif

  numTests = numTests + 1

 end subroutine TestRoeFluxExpansionShock


 subroutine TestRoeFluxZero

  rightState = 0
  call RoeFlux( leftState, rightState, interfaceFlux )

  ! IsRealEqual assertion
  numAsserts = numAsserts + 1
  if (noAssertFailed) then
   if (.not.( 0 +2*spacing(real( 0 )).ge. interfaceFlux &
             .and. 0 -2*spacing(real( 0 )).le. interfaceFlux)) then
    print *, " FAILURE: IsRealEqual in test RoeFluxZero, &
                       &line 47 of FluxFunctionsTS.ftk"
    print *, "   ", " interfaceFlux is not", 0 ,"within",2*spacing(real( 0 ))
    noAssertFailed = .false.
    numFailures    = numFailures + 1
   else
    numAssertsTested = numAssertsTested + 1
   endif
  endif

  ! IsEqual assertion
  numAsserts = numAsserts + 1
  if (noAssertFailed) then
   if (.not.( interfaceFlux== 0 )) then
    print *, " FAILURE: IsEqual in test RoeFluxZero, &
                       &line 48 of FluxFunctionsTS.ftk"
    print *, "   ", " interfaceFlux is not",  0 
    noAssertFailed = .false.
    numFailures    = numFailures + 1
   else
    numAssertsTested = numAssertsTested + 1
   endif
  endif

  numTests = numTests + 1

 end subroutine TestRoeFluxZero


 subroutine Setup
  leftState  = 0
  rightState = 1
  noAssertFailed = .true.
 end subroutine Setup


 subroutine Teardown
 end subroutine Teardown


 subroutine TSFluxFunctions( nTests, nAsserts, nAssertsTested, nFailures )

  integer :: nTests
  integer :: nAsserts
  integer :: nAssertsTested
  integer :: nFailures

  continue

  call Setup
  call TestFluxZero
  call Teardown

  call Setup
  call TestFluxOne
  call Teardown

  call Setup
  call TestRoeAvgZero
  call Teardown

  call Setup
  call TestRoeAvgKnown
  call Teardown

  call Setup
  call TestCentralFluxKnown
  call Teardown

  call Setup
  call TestRoeFluxExpansionShock
  call Teardown

  call Setup
  call TestRoeFluxZero
  call Teardown

  nTests          = numTests
  nAsserts        = numAsserts
  nAssertsTested  = numAssertsTested
  nFailures       = numFailures

 end subroutine TSFluxFunctions

end module FluxFunctionsTS
