# $Id$

# Fortran TestKit sample makefile

F9X = lf95		# Lahey compiler
F9X = f90 -macro_expand # SGI compiler

EXECUTABLE = TestRunner
SOURCES = GasModel.f90 FTK.f90 GasModelTest.F90 TestRunner.f90
INCLUDE = FTK.h

default: $(EXECUTABLE) test

$(EXECUTABLE): $(SOURCES) $(INCLUDE)
	$(F9X) -o $(EXECUTABLE) $(SOURCES)

test: $(EXECUTABLE)
	./$(EXECUTABLE)

clean:
	/bin/rm -f *.mod *.o $(EXECUTABLE)
