module Funit

  def requested_modules(module_names)
    if (module_names.empty?)
      module_names = Dir["*.fun"].each{ |mod| mod.chomp! ".fun" }
    end
    module_names
  end

  def funit_exists?(module_name)
    File.exists? module_name+".fun"
  end

  def parse_command_line

    module_names = requested_modules(ARGV)

    if module_names.empty?
      raise "   *Error: no test suites found in this directory"
    end

    module_names.each do |mod|
      unless funit_exists?(mod) 
        error_message = <<-FUNITDOESNOTEXIST
 Error: could not find test suite #{mod}.fun
 Test suites available in this directory:
 #{requested_modules([]).join(' ')}

 Usage: #{File.basename $0} [test names (w/o .fun suffix)]
        FUNITDOESNOTEXIST
        raise error_message
      end
    end

  end

  def write_test_runner test_suites

    File.delete("TestRunner.f90") if File.exists?("TestRunner.f90")
    test_runner = File.new "TestRunner.f90", "w"

    test_runner.puts <<-HEADER
! TestRunner.f90 - runs test suites
!
! #{File.basename $0} generated this file on #{Time.now}.

program TestRunner

    HEADER

    test_suites.each { |test_suite| test_runner.puts " use #{test_suite}_fun" }

    test_runner.puts <<-DECLARE

 implicit none

 integer :: numTests, numAsserts, numAssertsTested, numFailures
    DECLARE

    test_suites.each do |test_suite|
      test_runner.puts <<-TRYIT

 print *, ""
 print *, "#{test_suite} test suite:"
 call test_#{test_suite}( numTests, &
        numAsserts, numAssertsTested, numFailures )
 print *, "Passed", numAssertsTested, "of", numAsserts, &
          "possible asserts comprising", &
           numTests-numFailures, "of", numTests, "tests." 
      TRYIT
    end

    test_runner.puts "\n print *, \"\""
    test_runner.puts "\nend program TestRunner"
    test_runner.close
  end

  def syntax_error( message, test_suite )
    raise "\n   *Error: #{message} [#{test_suite}.fun:#$.]\n\n"
  end

  def warning( message, test_suite )
    $stderr.puts "\n *Warning: #{message} [#{test_suite}.fun:#$.]"
  end

  def compile_tests test_suites
    puts "computing dependencies"
    dependencies = Depend.new(['.', '../LibF90', '../PHYSICS_DEPS'])
    puts "locating associated source files and sorting for compilation"
    required_sources = dependencies.required_source_files('TestRunner.f90')

    puts compile = "#{ENV['FC']} #{ENV['FCFLAGS']} -o TestRunner \\\n  #{required_sources.join(" \\\n  ")}"

    raise "Compile failed." unless system(compile)
  end

end

#--
# Copyright 2006-2007 United States Government as represented by
# NASA Langley Research Center. No copyright is claimed in
# the United States under Title 17, U.S. Code. All Other Rights
# Reserved.
#
# This file is governed by the NASA Open Source Agreement.
# See License.txt for details.
#++