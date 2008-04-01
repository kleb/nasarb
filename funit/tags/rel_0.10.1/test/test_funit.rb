require 'test/unit'
require 'funit'
require 'ftools' # FIXME: migrate to fileutils

class TestFunit < Test::Unit::TestCase

  alias_method :tu_assert_equal, :assert_equal # avoid collision with test/unit

  include Funit # FIXME
  include Funit::Assertions # FIXME

  def setup
    File.rm_f(*Dir["dummyunit*"])
    File.rm_f(*Dir["unit*"])
    File.rm_f(*Dir["another*"])
    File.rm_f(*Dir["ydsbe*"])
    File.rm_f(*Dir["lmzd*"])
    File.rm_f(*Dir["ldfdl*"])
    File.rm_f(*Dir["ydsbe*"])
    File.rm_f(*Dir["*TestRunner*"])
  end

  def teardown
    File.rm_f(*Dir["dummyunit*"])
    File.rm_f(*Dir["unit*"])
    File.rm_f(*Dir["another*"])
    File.rm_f(*Dir["ydsbe*"])
    File.rm_f(*Dir["lmzd*"])
    File.rm_f(*Dir["ldfdl*"])
    File.rm_f(*Dir["ydsbe*"])
    File.rm_f(*Dir["*TestRunner*"])
  end

  def test_empty_test_runner_created_and_compilable
    write_test_runner []
    assert File.exists?("TestRunner.f90"), 'TestRunner.f90 not created.'
    compile_tests []
    assert File.exists?("makeTestRunner"), 'makeTestRunner.f90 not created.'
    assert system("make -f makeTestRunner"), 'make -f makeTestRunner failed.'
    assert File.exists?("TestRunner"), 'TestRunner executable not created.'
  end

  def test_is_equal
    @suite_name = "dummy"
    @test_name = "dummy"
    @line_number = "dummy"
    assert_equal("AssertEqual(1.0,m(1,1))")
    tu_assert_equal '.not.(1.0==m(1,1))', @condition
  end

  def test_is_real_equal
    @suite_name = "dummy"
    @test_name = "dummy"
    @line_number = "dummy"
    assert_real_equal("AssertRealEqual(a,b)")
    ans = <<-EOF
.not.( (a &\n        +2*spacing(real(a)) ) &\n        .ge. &\n        (b) &\n            .and. &\n     (a &\n      -2*spacing(real(a)) ) &\n      .le. &\n       (b) )
    EOF
    tu_assert_equal ans.chomp, @condition
    tu_assert_equal %|"b (", &\n b, &\n  ") is not", &\n a,&\n "within", &\n  2*spacing(real(a))|, @message
    assert_real_equal("AssertRealEqual(1.0,m(1,1))")
    ans = <<-EOF
.not.( (1.0 &\n        +2*spacing(real(1.0)) ) &\n        .ge. &\n        (m(1,1)) &\n            .and. &\n     (1.0 &\n      -2*spacing(real(1.0)) ) &\n      .le. &\n       (m(1,1)) )
    EOF
    tu_assert_equal ans.chomp, @condition
  end

  def test_should_accommodate_use_dependency_at_least_one_level_deep
    File.open('unit.f90','w') do |f|
      f.puts "module unit\n use another, only : a\nend module unit"
    end
    File.open('another.f90','w') do |f|
      f.puts "module another\n integer :: a = 5\nend module another"
    end
    File.open('unit.fun','w') do |f|
      f.puts "test_suite unit\ntest a_gets_set\nAssert_Equal(5,a)\nend test\nend test_suite"
    end
    assert_nothing_raised{run_tests}
  end

  def test_should_accommodate_doubly_embedded_use_dependencies
    File.open('unit.f90','w') do |f|
      f.puts "module unit\n use unita, only : a\nend module unit"
    end
    File.open('unita.f90','w') do |f|
      f.puts "module unita\n use unitb, only : b\n integer :: a = b\nend module unita"
    end
    File.open('unitb.f90','w') do |f|
      f.puts "module unitb\n integer, parameter :: b = 5\nend module unitb"
    end
    File.open('unit.fun','w') do |f|
      f.puts "begin test_suite unit\ntest a_gets_set\n Assert_Equal(5, a)\nend test\nend test_suite"
    end
    assert_nothing_raised{run_tests}
 end

  def test_should_accommodate_cap_F_extensions
    File.open('unit.F90','w') do |f|
      f.puts "module unit\n integer :: a = 1\nend module unit"
    end
    File.open('unit.fun','w') do |f|
      f.puts "begin test_suite unit\ntest a_gets_set\n Assert_Equal(1, a)\nend test\nend test_suite"
    end
    assert_nothing_raised{run_tests}
 end

  def test_requested_modules
    tu_assert_equal ["asdfga"], requested_modules(["asdfga"])
    tu_assert_equal ["asd","fga"], requested_modules(["asd","fga"])
    assert requested_modules([]).empty?
    modules = %w[ldfdl lmzd]
    funits = modules.map{|f| f+'.fun'}.join(' ')
    system "touch "+funits
    tu_assert_equal modules, requested_modules([])
  end

  def test_funit_exists_method
    module_name = "ydsbe"
    File.rm_f(module_name+".fun")
    tu_assert_equal false, funit_exists?(module_name)
    system "touch "+module_name+".fun"
    assert funit_exists?(module_name)
  end

end
