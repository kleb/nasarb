# $Id$

# Fortran TestKit sample makefile

F9X = lf95		# Lahey compiler
F9X = f90 -macro_expand # SGI compiler

TESTKIT = FTK.f90
INCLUDE = FTK.h

include TestBits.mk

CODE    = $(SOURCES) $(TESTKIT) $(TESTS) $(RUNNER)

default: $(EXECUTABLE) test

$(EXECUTABLE): $(CODE) $(INCLUDE)
	$(F9X) -o $(EXECUTABLE) $(CODE)

test: $(EXECUTABLE)
	./$(EXECUTABLE)

clean:
	/bin/rm -f *.mod *.o $(EXECUTABLE) $(RUNNER)
