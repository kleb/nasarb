! $Id$
program TestRunner

  use FTK

  implicit none

  print *, ""
  print *, "GasModelTest:"
  call TestGasModel

  print *, ""
  print *, "FluxFunctionsTest:"
  call TestFluxFunctions

  print *, ""
  print *, "GenericTest:"
  call TestGeneric

  print *, ""

end program TestRunner
