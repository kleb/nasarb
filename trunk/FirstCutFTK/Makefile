# $Id$

# A crude makefile for the first cut at FTK

default: it

it: testKit.f90 adder.f90 adderTest.f90 TestAll.f90
	f90 -cpp -o TestAll testKit.f90 adder.f90 adderTest.f90 TestAll.f90

clean:
	/bin/rm *.mod *.o TestAll
