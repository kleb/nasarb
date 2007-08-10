Uq4sim

* http://rubyforge.org/projects/nasarb
* http://nasarb.rubyforge.org
* mailto:Bil.Kleb@NASA.gov

== DESCRIPTION:

Uncertainty quantification for numerical simulations.

The purpose of this software is twofold: to document model
parameter uncertainties and to automate sensitivity analyses
for numerical modeling and simulation codes.  To this end,
a natural-language-based method to specify tolerances has
been developed where uncertainties can be expressed in a
natural manner, i.e., as one would on an engineering drawing,
namely with plus/minus tolerances like, 5.25+/-0.01.

This approach is robust and readily adapted to various application
domains because it does not rely on parsing the <em>particular</em>
structure of input file formats.  Instead, tolerances of a standard
format are added to existing fields within an input file.

== FEATURES/PROBLEMS:
  
* Provides in situ documentation of model parameter uncertainties.
* Readily adapted to existing modeling and simulation codes.
* Currently uses Monte-Carlos sampling, which is inefficient.
* Because thousands of runs are necessary to obtain valid statistics,
  this tool should only be considered for simulations that
  only take a few minutes to run.

== SYNOPSIS:

* <tt>uq4sim</tt>

== REQUIREMENTS:

* Ruby with Rubygems

== INSTALL:

* <tt>sudo gem install uq4sim</tt>

== LICENSE:

Uq4sim is released under the NASA Open Source Agreement -- see License.txt[link:files/License_txt.html] for details.
