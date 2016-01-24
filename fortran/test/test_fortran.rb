require 'test/unit'
require 'fortran'
require 'fileutils'

class TestFortran < Test::Unit::TestCase

  def setup
    Dir.mkdir 'DependenciesFixture'
    Dir.chdir 'DependenciesFixture' # FIXME: use block form for readability
    Dir.mkdir 'lib'
    Dir.chdir 'lib'
    File.open('solution.f90','w') do |f|
      f.puts "module solution\nuse area\nend module solution"
    end
    Dir.chdir '..'
    Dir.mkdir 'src'
    Dir.chdir 'src'
    File.open('main.F90','w') do |f|
      f.puts 'program whizzard'
      f.puts " use grid\n use solution\n use circle"
      f.puts 'end program whizzard'
    end
    File.open('grid.f90','w') do |f|
      f.puts "module grid\nuse area\nend module grid"
    end
    File.open('shapes.f90','w') do |f|
      f.puts "module rectangle_fun3d\nend module rectangle_fun3d"
      f.puts "module circle\n use area\nend module circle"
    end
    File.open('area.f90','w'){ |f| f.puts "module area\nend module area" }
    File.open('externalUse.f90','w') do |f|
      f.puts "program user\nuse cantFindModule\nend program"
    end
    @dep = Fortran::Dependencies.new
  end

  def teardown
    Dir.chdir '../..'
    FileUtils.rm_rf 'DependenciesFixture'
  end

  def test_finds_which_modules_a_source_file_uses
    assert_equal %w[grid solution circle], @dep.modules_used_in( 'main.F90' )
  end

  def test_finds_modules_defined_in_source_file
    assert_equal %w[rectangle_fun3d circle],
                 @dep.modules_defined_in( 'shapes.f90' )
  end

  def test_create_module_definition_hash
    assert_equal %w[circle rectangle_fun3d],
    @dep.build_dictionary_of_modules( ['shapes.f90'] ).keys.sort
  end

  def test_locating_all_fortran_files_in_search_path
    files = %w[ ../lib/solution.f90 area.f90 externalUse.f90
                grid.f90 main.F90 shapes.f90 ]
    @dep.find_fortran_files.each do |file|
      assert files.include?(file)
    end
  end

  def test_build_hash_with_source_files
    f90 = %w[grid.f90 ../lib/solution.f90 shapes.f90 area.f90]
    hash = @dep.build_dictionary_of_modules( f90 )
    assert_equal %w[ shapes.f90 shapes.f90 area.f90
                     ../lib/solution.f90 grid.f90 ].sort,
                 hash.values.sort
    assert_equal %w[ rectangle_fun3d circle area solution grid ].sort,
                 hash.keys.sort
    assert_equal hash , @dep.build_hash_of_modules_in_files
  end

  def test_dependency_generation_elements
    directoryHash = @dep.build_hash_of_modules_in_files

    source_file = "main.F90"
    modules = @dep.modules_used_in( source_file )
    assert_equal %w[grid solution circle], modules
    
    new_source_files = modules.collect{ |mod| directoryHash[mod] }
    assert_equal %w[ grid.f90 ../lib/solution.f90 shapes.f90],
                 new_source_files
    
    new_modules = new_source_files.collect do |file|
      @dep.modules_used_in( file )
    end.flatten.uniq

    assert_equal ["area"], new_modules
  end

  def test_makefile_dependency_line_generation
    source_file = "main.F90"
    make_golden=String.new <<-GOLDEN
main.o: main.F90 \\
 grid.o \\
 solution.o \\
 shapes.o
    GOLDEN
    assert_equal make_golden, @dep.makefile_dependency_line(source_file)
  end

  def test_makefile_dependency_recurses_properly
    make_golden=String.new <<-GOLDEN
main.o: main.F90 \\
 grid.o \\
 solution.o \\
 shapes.o
grid.o: grid.f90 \\
 area.o
area.o: area.f90
solution.f90: ../lib/solution.f90
\tln -sf ../lib/solution.f90 .
solution.o: solution.f90 \\
 area.o
shapes.o: shapes.f90 \\
 area.o
    GOLDEN

    gold_split = make_golden.split("\n")
    test_split = @dep.dependencies('main.F90').split("\n")

    while (gold = gold_split.shift) && (test = test_split.shift)
      assert_equal gold, test
    end
  end

  def test_source_file_dependency_hash
    @dep.source_file_dependencies('main.F90')
    assert_equal( 5, @dep.file_dependencies.size )
    expected = {
      "area.f90" => [],
      "grid.f90" => ["area.f90"],
      "../lib/solution.f90" => ["area.f90"],
      "shapes.f90" => ["area.f90"],
      "main.F90" => ["grid.f90", "../lib/solution.f90", "shapes.f90"]
    }
    assert_equal expected, @dep.file_dependencies
  end

  def test_finds_required_source_files
    expected = %w[ area.f90 shapes.f90 ../lib/solution.f90
                   grid.f90 main.F90 ]
    found = @dep.required_source_files('main.F90')
    assert_equal expected.size, found.size
    assert_equal 'main.F90', found.last
    assert_equal 'area.f90', found.first
  end

  def test_finds_required_source_files_unordered
    @dep.dependencies('main.F90')
    sources = @dep.source_files
    expected = %w[ main.F90 grid.f90 area.f90 solution.f90 shapes.f90 ]
    assert_equal expected.size, sources.size
    assert_equal 'shapes.f90', sources.last
    assert_equal 'main.F90', sources.first
    assert_equal expected, sources
  end

  def test_can_find_required_source_files_twice
    files = %w[ main.F90 shapes.f90 area.f90
                ../lib/solution.f90 grid.f90 ]
    @dep.required_source_files('main.F90')
    assert_equal files.sort, @dep.required_source_files('main.F90').sort
  end

  def test_recognizes_external_modules
    file = 'externalUse.f90'
    assert_equal [file], @dep.required_source_files(file).sort
  end

end
