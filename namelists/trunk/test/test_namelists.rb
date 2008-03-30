require 'test/unit/testcase'
require 'namelists'

$laura_io = File.read("#{ENV['HOME']}/Projects/FUN3D/LAURA/io_laura.f90")

class TestNamelists < Test::Unit::TestCase
  def test_finds_namelist_definition
    content = "program main\n  namelist /name/ var1, &\n   var2\nend"
    namelists = Namelists.new(content).find_definitions
    assert namelists.has_key?('name')
    assert_equal %w[ var1 var2 ], namelists['name']
    namelists = Namelists.new($laura_io).find_definitions
    assert namelists.has_key?('laura_namelist')
    assert_equal 84, namelists['laura_namelist'].size
  end
  def test_should_strip_comments
    assert_equal '', Namelists.new("! stuff\n").strip_comments
    assert_equal "x=1\n", Namelists.new("x=1 ! origin\n").strip_comments
  end
  def test_should_collapse_continuations
    assert_equal "x=1 +1\n", Namelists.new("x=1 &\n +1\n").collapse_continuations
  end
  def test_should_extract_namelist_description
    assert_equal 1, Namelists.new("! begin namelist /test/ description\n var1=0.0\nvar2=5\n! end namelist /test/ description").parse_description.size
    description = Namelists.new($laura_io).parse_description
    assert_equal 1, description.size
  end
end
