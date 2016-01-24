= namelists

* http://nasarb.rubyforge.org/namelists

== DESCRIPTION:

Generates webpage for creating namelists found in Fortran programs.

== FEATURES/PROBLEMS:

* Keep namelist documentation DRY
* Generate GUI for namelist input from source code

== SYNOPSIS:

  namelists

== REQUIREMENTS:

* Ruby

== INSTALL:

* sudo gem install namelists

== LICENSE:

Namelists is released under the NASA Open Source Agreement -- see License.txt[link:files/License_txt.html] for details.

== TODO:

Cases to consider:

- default is a variable, not a literal -- see grid_motion_helpers.f90 and
  surface.f90

- variables included from another module -- see turbulence_parameters.f90

- zero-based array variables -- see surface.f90

- variable is tensor, e.g., n(1), n(2), n(3) normal or transformation
  matrix -- see sixdof.F90

- variable is an indexed array dependent on some integer input,
  or worse, a tensor of integers, e.g., defining_bndry(i,j) -- see
  grid_motion_helpers.f90; and possibly even worse, the addressing
  is spans two levels -- see solution_globals.f90

- mixture of declaration defaults and executable defaults -- see gq_coeff.f90

