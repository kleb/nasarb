#! /usr/bin/env ruby

$:.unshift File.join( File.dirname(__FILE__), '..', 'lib' )

require 'test/unit'
require 'funit'
require 'ftools'

class TestFunit < Test::Unit::TestCase

  include Funit
  include Funit::Assertions

  def setup
    File.rm_f(*Dir["dummyunit*"])
    File.rm_f(*Dir["unit*"])
    File.rm_f(*Dir["ydsbe*"])
    File.rm_f(*Dir["lmzd*"])
    File.rm_f(*Dir["ldfdl*"])
    File.rm_f(*Dir["ydsbe*"])
    File.rm_f(*Dir["TestRunner*"])
    File.rm_f(*Dir["a.out"])
  end

  def teardown
    File.rm_f(*Dir["dummyunit*"])
    File.rm_f(*Dir["unit*"])
    File.rm_f(*Dir["ydsbe*"])
    File.rm_f(*Dir["lmzd*"])
    File.rm_f(*Dir["ldfdl*"])
    File.rm_f(*Dir["ydsbe*"])
    File.rm_f(*Dir["TestRunner*"])
    File.rm_f(*Dir["a.out"])
  end

  def test_main_driver_compiles
    writeTestRunner []
    assert File.exists?("TestRunner.f90")
    assert system("#{Compiler.new.name} TestRunner.f90")
    assert File.exists?("a.out")
  end

  def test_is_equal
    @suiteName = "dummy"
    @testName = "dummy"
    @lineNumber = "dummy"
    isequal("IsEqual(1.0,m(1,1))")
    assert_equal '.not.(1.0==m(1,1))', @condition
  end 

  def test_is_real_equal
    @suiteName = "dummy"
    @testName = "dummy"
    @lineNumber = "dummy"
    isrealequal("IsRealEqual(a,b)")
    ans = <<-EOF
.not.(a+2*spacing(real(a)).ge.b &
             .and.a-2*spacing(real(a)).le.b)
    EOF
    assert_equal ans.chomp, @condition
    assert_equal '"b (",b,") is not",a,"within",2*spacing(real(a))', @message
    isrealequal("IsRealEqual(1.0,m(1,1))")
    ans = <<-EOF
.not.(1.0+2*spacing(real(1.0)).ge.m(1,1) &
             .and.1.0-2*spacing(real(1.0)).le.m(1,1))
    EOF
    assert_equal ans.chomp, @condition
  end

  def test_handles_dependency
    File.open('unit.f90','w') do |f|
      f.printf "module unit\n  use unita, only : a\nend module unit\n"
    end
    File.open('unita.f90','w') do |f|
      f.printf "module unita\n  integer :: a = 5\nend module unita\n"
    end
    File.open('unit.fun','w') do |f|
      f.printf "beginTest a_gets_set\n  IsEqual(5, a)\nendTest\n"
    end
    assert_nothing_raised{run_tests}
  end

  def test_embedded_dependencies
    File.open('unit.f90','w') do |f|
      f.printf "module unit\n  use unita, only : a\nend module unit\n"
    end
    File.open('unita.f90','w') do |f|
      f.printf "module unita\n  use unitb, only : b \n  integer :: a = b\nend module unita\n"
    end
    File.open('unitb.f90','w') do |f|
      f.printf "module unitb\n  integer,parameter :: b = 5\nend module unitb\n"
    end
    File.open('unit.fun','w') do |f|
      f.printf "beginTest a_gets_set\n  IsEqual(5, a)\nendTest\n"
    end
    assert_nothing_raised{run_tests}
 end

  def test_requested_modules
    assert_equal ["asdfga"], requestedModules(["asdfga"])
    assert_equal ["asd","fga"], requestedModules(["asd","fga"])
    assert requestedModules([]).empty?
    modules = %w[ldfdl lmzd]
    funits = modules.map{|f| f+'.fun'}.join(' ')
    system "touch "+funits
    assert_equal modules, requestedModules([])
  end

  def test_funit_exists_method
    moduleName = "ydsbe"
    File.rm_f(moduleName+".fun")
    assert_equal false, funit_exists?(moduleName)
    system "touch "+moduleName+".fun"
    assert funit_exists?(moduleName)
  end

end
