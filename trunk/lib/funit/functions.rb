# Compile and run the requested tests

module Funit

  class Compiler

    attr_reader :name

    def initialize( name=ENV['FC'] )
      errorMessage = <<-ENVIRON

Fortran compiler environment variable 'FC' not set:

 for bourne-based shells: export FC=lf95 (in .profile)
      for c-based shells: setenv FC lf95 (in .login)
             for windows: set FC=C:\\Program Files\\lf95 (in autoexec.bat)

      ENVIRON
      raise(errorMessage) unless @name = name
    end

  end # class

  def requestedModules(moduleNames)
    if (moduleNames.empty?)
      moduleNames = Dir["*.fun"].each{ |mod| mod.chomp! ".fun" }
    end
    moduleNames
  end

  def funit_exists?(moduleName)
    File.exists? moduleName+".fun"
  end

  def parseCommandLine

    moduleNames = requestedModules(ARGV)

    if moduleNames.empty?
      raise "   *Error: no test suites found in this directory"
    end

    moduleNames.each do |mod|
      unless funit_exists?(mod) 
        errorMessage = <<-FUNITDOESNOTEXIST
 Error: could not find test suite #{mod}.fun
 Test suites available in this directory:
 #{requestedModules([]).join(' ')}

 Usage: #{File.basename $0} [test names (w/o .fun suffix)]
        FUNITDOESNOTEXIST
        raise errorMessage
      end
    end

  end

  def writeTestRunner testSuites

    File.delete("TestRunner.f90") if File.exists?("TestRunner.f90")
    testRunner = File.new "TestRunner.f90", "w"

    testRunner.puts <<-HEADER
! TestRunner.f90 - runs test suites
!
! #{File.basename $0} generated this file on #{Time.now}.

program TestRunner

    HEADER

    testSuites.each { |testSuite| testRunner.puts " use #{testSuite}_fun" }

    testRunner.puts <<-DECLARE

 implicit none

 integer :: numTests, numAsserts, numAssertsTested, numFailures
    DECLARE

    testSuites.each do |testSuite|
      testRunner.puts <<-TRYIT

 print *, ""
 print *, "#{testSuite} test suite:"
 call test_#{testSuite}( numTests, &
        numAsserts, numAssertsTested, numFailures )
 print *, "Passed", numAssertsTested, "of", numAsserts, &
          "possible asserts comprising", &
           numTests-numFailures, "of", numTests, "tests." 
      TRYIT
    end

    testRunner.puts "\n print *, \"\""
    testRunner.puts "\nend program TestRunner"
    testRunner.close
  end

  def syntaxError( message, testSuite )
    raise "\n   *Error: #{message} [#{testSuite}.fun:#$.]\n\n"
  end

  def warning( message, testSuite )
    $stderr.puts "\n *Warning: #{message} [#{testSuite}.fun:#$.]"
  end

  def compileTests testSuites
    puts "computing dependencies"
    dependencies = Depend.new(['.', '../LibF90', '../PHYSICS_DEPS'])
    puts "locating associated source files and sorting for compilation"
    requiredSources = dependencies.required_source_files('TestRunner.f90')

    puts compile = "#{ENV['FC']} #{ENV['FCFLAGS']} -o TestRunner \\\n  #{requiredSources.join(" \\\n  ")}"

    raise "Compile failed." unless system(compile)
  end

  # set some regular expressions:
  $keyword = /(begin|end)(Setup|Teardown|Test)|Is(RealEqual|Equal|False|True|EqualWithin)\(.*\)/i
  $commentLine = /^\s*!/

end # module

#--
# Copyright 2006 United States Government as represented by
# NASA Langley Research Center. No copyright is claimed in
# the United States under Title 17, U.S. Code. All Other Rights
# Reserved.
#
# This file is governed by the NASA Open Source Agreement.
# See License.txt for details.
#++