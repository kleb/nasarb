# $Id$

# A crude makefile for the first cut at FTK

F9X = lf95		# Lahey compiler
F9X = f90 -macro_expand # SGI compiler

EXECUTABLE = TestAll
SOURCES = adder.f90 testKit.f90 adderTest.F90 TestAll.f90
INCLUDE = testKit.inc

default: $(EXECUTABLE)

$(EXECUTABLE): $(SOURCES) $(INCLUDE)
	$(F9X) -o $(EXECUTABLE) $(SOURCES) 

clean:
	/bin/rm -f *.mod *.o $(EXECUTABLE)
