# $Id$

# Fortran TestKit sample makefile

F9X = lf95		# Lahey compiler
F9X = f90 -macro_expand # SGI compiler

EXECUTABLE = TestRunner

SOURCES = GasModel.f90\
	  FluxFunctions.f90
TESTKIT = FTK.f90
TESTS   = GasModelTest.F90\
	  FluxFunctionsTest.F90\
	  GenericTest.F90
RUNNER  = TestRunner.f90
CODE    = $(SOURCES) $(TESTKIT) $(TESTS) $(RUNNER)

INCLUDE = FTK.h

default: $(EXECUTABLE) test

$(EXECUTABLE): $(CODE) $(INCLUDE)
	$(F9X) -o $(EXECUTABLE) $(CODE)

test: $(EXECUTABLE)
	./$(EXECUTABLE)

clean:
	/bin/rm -f *.mod *.o $(EXECUTABLE)
