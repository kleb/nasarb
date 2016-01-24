require 'test/unit'
require 'funit/testsuite'

require 'fileutils'
include FileUtils

class TestTestSuite < Test::Unit::TestCase

  def setup
    files = *Dir["dummyf90test*"]
    rm_f files if files
  end 

  def teardown
    files = *Dir["dummyf90test*"]
    rm_f files if files
  end 

  def test_nonexistent_funit_file_is_not_created
    Funit::TestSuite.new 'dummyf90test', '', false
    assert !File.exists?("dummyf90test.fun")
    assert !File.exists?("dummyf90test_fun.f90")
  end

  def create_funit_file funit_contents
    File.open('dummyf90test.f90','w') do |f|
      f.puts "module dummyf90test\nend module dummyf90test"
    end
    File.open('dummyf90test.fun','w') do |f|
      f.puts funit_contents
    end
  end

  @@compileCommand = "#{ENV['FC']} -c dummyf90test.f90 dummyf90test_fun.f90"

  def test_bare_minimum_funit_file_compiles
    create_funit_file ""
    Funit::TestSuite.new 'dummyf90test', '', false
    assert system(@@compileCommand)
  end

  def test_module_variables_allowed
    create_funit_file "integer :: a"
    Funit::TestSuite.new 'dummyf90test', '', false
    assert system(@@compileCommand)
  end

  def test_blank_setup_compiles
    create_funit_file "beginSetup\nendSetup"
    Funit::TestSuite.new 'dummyf90test', '', false
    assert system(@@compileCommand)
  end

  def test_blank_test_gives_warning
    create_funit_file "beginTest bob\nendTest"
    Funit::TestSuite.new 'dummyf90test', '', false
    assert system(@@compileCommand)
  end

  def test_single_assert_test_compiles
    create_funit_file "beginTest assertTrue\nAssertTrue(.true.)\nendTest"
    Funit::TestSuite.new 'dummyf90test', '', false
    assert system(@@compileCommand)
  end

  def test_matrix_assert_compiles
    create_funit_file <<-MATRIX
 beginTest assertTrue
  integer :: a(2,2)
  a = 1
  AssertEqual(1,a(1,1))
 endTest
    MATRIX
    Funit::TestSuite.new 'dummyf90test', '', false
    assert system(@@compileCommand)
  end

  def test_simple_real_equals_assert_works
    create_funit_file <<-REALEQUALS
 beginTest assert_equals
  real :: real_var
  real_var = 1.0
  AssertRealEqual(1.0,real_var)
 endTest
    REALEQUALS
    Funit::TestSuite.new 'dummyf90test', '', false
    assert system(@@compileCommand)
  end

  def test_real_equals_assert_works_with_function
    create_funit_file <<-REQUALSFUNC
 beginTest assert_equals_for_function
  AssertRealEqual(0.0,balance(0.0,0.0))
 endTest
 function balance( left, right)
  real :: balance
  real, intent(in) :: left, right
  balance = 0.5*(left+right)
 end function balance
    REQUALSFUNC
    Funit::TestSuite.new 'dummyf90test', '', false
    assert system(@@compileCommand)
  end

  def test_ignore_commented_test
    create_funit_file "XbeginTest bob\nendTest"
    Funit::TestSuite.new 'dummyf90test', '', false
    assert_no_match( /Testbob/i, IO.readlines('dummyf90test_fun.f90').join )
  end

end
