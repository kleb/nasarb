! GasModelTS.f90 - a Fortran mobility test suite for GasModel.f90
!
! [dynamically generated from GasModelTS.ftk
!  by FTKtest Ruby script Wed Nov 07 07:53:00 EST 2001]

module GasModelTS

 use GasModel

 implicit none

 private

 public :: TSGasModel

 logical :: noAssertFailed

 integer :: numTests          = 0
 integer :: numAsserts        = 0
 integer :: numAssertsTested  = 0
 integer :: numFailures       = 0

! $Id$

 real            :: Pressure, Density, Energy

 contains

 subroutine TestPerfectPZeroed

  real, parameter :: zero = 0
  call PerfectP( zero, zero, Pressure)

  ! IsRealEqual assertion
  numAsserts = numAsserts + 1
  if (noAssertFailed) then
   if (.not.( 0 +2*spacing(real( 0 )).ge. Pressure &
             .and. 0 -2*spacing(real( 0 )).le. Pressure)) then
    print *, " FAILURE: IsRealEqual in test PerfectPZeroed, &
                       &line 8 of GasModelTS.ftk"
    print *, "   ", " Pressure is not", 0 ,"within",2*spacing(real( 0 ))
    noAssertFailed = .false.
    numFailures    = numFailures + 1
   else
    numAssertsTested = numAssertsTested + 1
   endif
  endif

  ! IsEqualWithin assertion
  numAsserts = numAsserts + 1
  if (noAssertFailed) then
   if (.not.( 0+ 0.0000000001 .ge. Pressure &
             .and. 0- 0.0000000001 .le. Pressure)) then
    print *, " FAILURE: IsEqualWithin in test PerfectPZeroed, &
                       &line 9 of GasModelTS.ftk"
    print *, "   ", " Pressure is not", 0,"within", 0.0000000001 
    noAssertFailed = .false.
    numFailures    = numFailures + 1
   else
    numAssertsTested = numAssertsTested + 1
   endif
  endif

  numTests = numTests + 1

 end subroutine TestPerfectPZeroed


 subroutine TestWarbler


  numTests = numTests + 1

 end subroutine TestWarbler


 subroutine TestPerfectPKnown

  real :: Density = 1
  Energy  = 1
  call PerfectP( Density, Energy, Pressure )

  ! IsRealEqual assertion
  numAsserts = numAsserts + 1
  if (noAssertFailed) then
   if (.not.( 0.4 +2*spacing(real( 0.4 )).ge. Pressure &
             .and. 0.4 -2*spacing(real( 0.4 )).le. Pressure)) then
    print *, " FAILURE: IsRealEqual in test PerfectPKnown, &
                       &line 19 of GasModelTS.ftk"
    print *, "   ", " Pressure is not", 0.4 ,"within",2*spacing(real( 0.4 ))
    noAssertFailed = .false.
    numFailures    = numFailures + 1
   else
    numAssertsTested = numAssertsTested + 1
   endif
  endif

  ! IsTrue assertion
  numAsserts = numAsserts + 1
  if (noAssertFailed) then
   if (.not.( Pressure .gt. 0 )) then
    print *, " FAILURE: IsTrue in test PerfectPKnown, &
                       &line 20 of GasModelTS.ftk"
    print *, "   ", " Pressure .gt. 0  is not true"
    noAssertFailed = .false.
    numFailures    = numFailures + 1
   else
    numAssertsTested = numAssertsTested + 1
   endif
  endif

  ! IsFalse assertion
  numAsserts = numAsserts + 1
  if (noAssertFailed) then
   if ( Pressure .lt. 0 ) then
    print *, " FAILURE: IsFalse in test PerfectPKnown, &
                       &line 21 of GasModelTS.ftk"
    print *, "   ", " Pressure .lt. 0  is not false"
    noAssertFailed = .false.
    numFailures    = numFailures + 1
   else
    numAssertsTested = numAssertsTested + 1
   endif
  endif

  numTests = numTests + 1

 end subroutine TestPerfectPKnown


 subroutine Setup
  noAssertFailed = .true.
 end subroutine Setup


 subroutine Teardown
 end subroutine Teardown


 subroutine TSGasModel( nTests, nAsserts, nAssertsTested, nFailures )

  integer :: nTests
  integer :: nAsserts
  integer :: nAssertsTested
  integer :: nFailures

  continue

  call Setup
  call TestPerfectPZeroed
  call Teardown

  call Setup
  call TestWarbler
  call Teardown

  call Setup
  call TestPerfectPKnown
  call Teardown

  nTests          = numTests
  nAsserts        = numAsserts
  nAssertsTested  = numAssertsTested
  nFailures       = numFailures

 end subroutine TSGasModel

end module GasModelTS
