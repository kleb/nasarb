require 'erb'

module Funit

  TEST_RUNNER = ERB.new %q{
    ! TestRunner.f90 - runs fUnit test suites
    !
    ! <%= File.basename $0 %> generated this file on <%= Time.now %>.

    program TestRunner
      <%= test_suites.inject('') { |result,test_suite| result << "\n  use #{test_suite}_fun" } %>

      implicit none

      integer,dimension(<%=test_suites.size%>) :: numTests, numAsserts, &
                                                 numAssertsTested, numFailures

      <% test_suites.each_index do |i| %>
      print *, ""
      print *, "<%= test_suites[i] %> test suite:"
      call test_<%= test_suites[i] %> &
        ( numTests(<%=i%>), numAsserts(<%=i%>), numAssertsTested(<%=i%>), numFailures(<%=i%>) )
      print *, "Passed", numAssertsTested(<%=i%>), "of", numAsserts(<%=i%>), &
               "possible asserts comprising",                &
               numTests(<%=i%>)-numFailures(<%=i%>), "of", numTests(<%=i%>), "tests."
      <% end %>
      print *, ""

      write(*,'(A)') "==========[ SUMMARY ]=========="
      <% max_length = test_suites.max{|a,b| a.length<=>b.length}.length %>
      <% test_suites.each_index do |i| %>
      write(*,'(A<%=max_length+2%>)',advance="no") " <%= test_suites[i] %>:"
      if(numFailures(<%=i%>)==0) then
        write(*,*) " passed"
      else
        write(*,*) " failed   <<<<<"
      end if
      <% end %>
      print *, ""
    end program TestRunner
    }.gsub(/^    /,''), nil, '<>' # turn off newlines due to <%%>

  MAKEFILE = ERB.new(%q{
    # makefile to compile TestRunner.f90
    #
    # <%= File.basename $0 %> generated this file on <%= Time.now %>.

    OBJ=<%= required_objects.join(' ') %>

    all:testrunner

    testrunner: $(OBJ)
    <%= "\t#{ENV['FC']}" %> -o TestRunner $(OBJ)

    <% file_dependencies.each do |h,d| %> 
     <%= h.chomp('.f90')+".o" %>: <%= h+"  "+d.map{|s| s.chomp('.f90')+".o"}.join(' ')+"\n" %>
     <%= "\tcd "+File.dirname(h) %>;<%= "#{ENV['FC']} #{sourceflag}" %> -c <%= File.basename(h) %>
    <% end %>

  }.gsub(/^ +/,''), nil, '<>')

  def requested_modules(module_names)
    if module_names.empty?
      module_names = Dir["*.fun"].each{ |mod| mod.chomp! ".fun" }
    end
    module_names
  end

  def funit_exists?(module_name)
    File.exists? "#{module_name}.fun"
  end

  def parse_command_line

    module_names = requested_modules(ARGV)

    if module_names.empty?
      raise "   *Error: no test suites found in this directory"
    end

    module_names.each do |mod|
      unless funit_exists?(mod) 
        error_message = <<-FUNIT_DOES_NOT_EXIST
 Error: could not find test suite #{mod}.fun
 Test suites available in this directory:
 #{requested_modules([]).join(' ')}

 Usage: #{File.basename $0} [test names (w/o .fun suffix)]
        FUNIT_DOES_NOT_EXIST
        raise error_message
      end
    end

  end

  def write_test_runner test_suites
    File.open("TestRunner.f90", "w") do |file|
      file.puts TEST_RUNNER.result(binding)
    end
  end

  def syntax_error( message, test_suite )
    raise "\n   *Error: #{message} [#{test_suite}.fun:#$.]\n\n"
  end

  def warning( message, test_suite )
    $stderr.puts "\n *Warning: #{message} [#{test_suite}.fun:#$.]"
  end

  def compile_tests(test_suites,prog_source_dir='.')
    puts "computing dependencies"

    # calculates parameters
    if(prog_source_dir=='.') then
      sourceflag = ""
    else
#      prog_source_dir = File.expand_path(prog_source_dir)  # commented as it doesn't seem necessary
      sourceflag = " "+ ENV['FSFLAG'] + prog_source_dir
    end
    current_dir = `pwd`.chomp
    sp = ['.'] + (prog_source_dir.empty? ? [] : [prog_source_dir])

    dependencies = Fortran::Dependencies.new(:search_paths=> sp)
    puts "locating associated source files and sorting for compilation"
    dependencies.source_file_dependencies('TestRunner.f90')
    file_dependencies = dependencies.file_dependencies
    required_objects = file_dependencies.values.flatten.uniq.map{|s|s.chomp('f90')+"o"}
    required_objects += ['TestRunner.o']

    File.open("makeTestRunner", "w") {|file| file.puts MAKEFILE.result(binding)}

    compile = "make -f makeTestRunner"

    raise "Compile failed." unless system compile
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
