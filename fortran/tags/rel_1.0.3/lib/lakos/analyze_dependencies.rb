#!/usr/bin/env ruby
#
# For a given directory, this routine will find the
# dependency levels of resident *90 files and various
# code complexify measures per Lakos' /Large Scale
# C++ Software Design/ book.
#
# Usage:
#
# To do an entire directory,
#
#  HEFSS.rps/FUN3D_90
#  ../Ruby/CASE_tools/analyze_dependencies.rb
#
# If a main.*90 is found, the results will be sorted by level
# and a HTML summary page will be produced to add navigation.
#
# To do a set of files, pass their names as arguments,
#
#  ../Ruby/CASE_tools/analyze_dependencies.rb main.F90 project.f90 [..]
#
# Results, consising of text and Graphviz dot files,
# are deposited in a subdirectory according to DROP_DIR
# set below.

SEARCH_PATH = %w[ ../LibF90 ../PHYSICS_MODULES ../PHYSICS_DEPS . ]
DROP_DIR = 'Lakos'

require 'fortran'

##
# add a deep clone method to completely duplicate hashes

class Object
  def deep_clone; Marshal::load(Marshal.dump(self)); end
end

##
# add a cleaning method for FUN3D file names

class String
  def fun3d_clean
    File.basename(self).sub(/_module/i,'').sub(/\.f90$/i,'')
  end
end

class DependencyAnalyzer

  attr_reader :use_deps, :tc_deps, :dd_deps, :lvl_deps,
              :levels, :components, :ccd, :acd, :nccd

  def initialize( head, search_path=SEARCH_PATH )
    @head = head
    @levels    = Hash.new{ |hash,key| hash[key]=Array.new }
    @tc_deps   = Hash.new{ |hash,key| hash[key]=Array.new }
    @use_deps  = Hash.new
    shorten_dependency_file_names(find_file_dependencies(head,search_path))
    find_levels_of_dependencies(@use_deps.deep_clone)
    find_transitive_closure_graph
    compute_stats
    find_direct_dependencies_graph
    find_level_dependencies_graph
  end

  def compute_stats
    @components = 0;  @levels.each_value{ |v| @components += v.size }
    @ccd = 0; @tc_deps.each_value{ |dependents| @ccd += dependents.size + 1 }
    @acd = @ccd/@components.to_f
    ccd_binary_tree = (@components+1)*(Math::log(@components+1)/Math::log(2)-1)+1
    @nccd = @ccd / ccd_binary_tree
  end

  def find_file_dependencies( head, search_path )
    depend = Fortran::Dependencies.new( :search_path => search_path )
    depend.source_file_dependencies(head)
    depend.file_dependencies
  end

  def shorten_dependency_file_names(deps)
    deps.each_pair do |file,dependents|
      @use_deps[file] = dependents
    end
  end

  def find_transitive_closure_graph
    # turn the hash into a sorted array to assure bottom-to-top ordering
    @levels.sort.each do |pair|
      components = pair.last
      components.each do |component|
        @tc_deps[component] = @use_deps[component].clone
        @use_deps[component].each do |dependent|
          @tc_deps[component].push @tc_deps[dependent].clone
        end
        @tc_deps[component].flatten!
        @tc_deps[component].uniq!
      end
    end
  end

  def find_direct_dependencies_graph
    @dd_deps = Hash.new
    @tc_deps.each{|k,v| @dd_deps[k] = @tc_deps[k].clone}
    # turn the hash into a sorted array to assure bottom-to-top ordering
    @levels.sort.each do |pair|
      components = pair.last
      components.each do |component|
        @dd_deps[component].each do |dependent|
          @dd_deps[component] -= @dd_deps[dependent]
        end
      end
    end
  end

  def level_of(component)
    @levels.
    select{ |level,components| components.include?(component) }.
    flatten.first
  end

  # only the dependencies "holding up" the levels
  def find_level_dependencies_graph
    long_distance_dependents = Array.new
    @lvl_deps =  @dd_deps.deep_clone
    @levels.sort.reverse.each do |pair|
      level, components = pair
      components.each do |component|
        long_distance_dependents.clear
        @dd_deps[component].each do |dependent|
          long_distance_dependents << dependent if level_of(dependent) < level-1
        end
        @lvl_deps[component] -= long_distance_dependents
      end
    end
  end

  def find_levels_of_dependencies(deps)
    level = 1
    until deps.empty? do
      deps.each{ |file,dependents| @levels[level] << file if dependents.empty? }
      deps.delete_if{ |file,dependents| @levels[level].include?(file) }
      deps.each do |file,dependents|
        dependents.delete_if{ |dependent| @levels[level].include?(dependent) }
      end
      level += 1
    end
    @levels
  end

  def summary
    result = Array.new
    result << "COMPONENT:\n"
    result << " #@head"
    result << "\nSUMMARY:\n"
    result << " Components: #@components"
    result << "     Levels: #{@levels.size}"
    result << "        CCD: #@ccd [Cumulative Component Dependency]"
    result << "        ACD: #{sprintf('%.1f',@acd)} (average CD)"
    result << "       NCCD: #{sprintf('%.2f',@nccd)} (normalized CCD -- desired: 0.85 to 1.10)"
    result << "\nLEVELS:\n"
    @levels.sort.each do |pair|
      result << "#{pair.first}:".rjust(3)
      pair.last.each{ |component| result << "   #{component.sub(/\.*\//,'')}" }
    end
    result.join "\n"
  end

  def graph( deps )
    graph = ''
    graph << "digraph G {\n"
    graph << " ratio=0.67;\n"
    graph << " label=\"#{File.basename(Dir.pwd)}/#{@head}\\n"
    graph << "#{Time.now}\\n"
    graph << "Lakos Levels/Components/CCD/ACD/NCCD\\n"
    graph << "#{@levels.size}/#@components/#@ccd/#{sprintf('%.1f',@acd)}/#{sprintf('%.2f',@nccd)}\\n"
    graph << "\";\n"
    #  graph << " nodesep=0.3;\n"
    graph << " fontname=GillSans; fontsize=24;\n"
    graph << " node [fontname=GillSans,fontsize=24,shape=plaintext];\n"
    graph << " edge [arrowhead=none];\n"
    graph << "{ node [shape=box];"
    (@levels.size).downto(2){ |lvl| graph << " #{lvl}->#{lvl-1};" }
    graph << " };\n"
    @levels.each do |level,components|
      graph << "{ rank = same; #{level}; \"#{components.map{|c| c.fun3d_clean}.join('"; "')}\"; }\n"
    end
    deps.each do |file,dependents|
      dependents.each do |dependent|
        graph << "\"#{file.fun3d_clean}\" -> \"#{dependent.fun3d_clean}\";\n"
      end
    end
    graph << "}"
    graph
  end

end # class

if $0 == __FILE__ then

  require 'fileutils'

  dot_capable = system("which dot") and system("which epstopdf")

  Dir.mkdir DROP_DIR unless File.exist? DROP_DIR

  if ARGV.empty?
    directory = true
    files = Dir["*90"]
  else
    directory = false
    files = ARGV.map{|a| a.dup}
  end

  files.delete_if{ |f| !File.exists? f }

  # sort the file list by level if the big cahuna is present
  if directory
    if files.include?('main.F90') then
      da = DependencyAnalyzer.new( 'main.F90' )
    elsif files.include?('main.f90') then
      da = DependencyAnalyzer.new( 'main.f90' )
    end
    files.clear
    da.levels.sort.reverse.each{|pair| files.push pair.last }
    files.flatten!
  end

  File.open(File.join(DROP_DIR,'index.html'),'w') do |index|

    pwd = File.basename(Dir.pwd)

    index.puts "<html>"
    index.puts " <head><title>#{pwd}</title></head>"
    index.puts "<body>"
    index.puts "<h1>#{pwd}</h1>"
    index.puts "Data generated by #$0 at #{Time.now}."
    index.puts "<table cellspacing=10>"
    index.puts " <tr>"
    index.puts "  <th colspan=5>Statistics</th>"
    index.puts "  <th></th>"
    index.puts "  <th colspan=2>Dependency Plots</th>"
    index.puts " </tr>"
    index.puts " <tr>"
    index.puts "  <th>Level</th>"
    index.puts "  <th>#Cs</th>"
    index.puts "  <th>CCD</th>"
    index.puts "  <th>ACD</th>"
    index.puts "  <th>NCCD</th>"
    index.puts "  <th></th>"
    index.puts "  <th>Use</th>"
    index.puts "  <th>Level</th>"
    index.puts "  <th align=left>Source</th>"
    index.puts " </tr>"

    files.each_with_index do |file,number|

      $stderr.puts "Analyzing #{number+1} of #{files.size}: #{file}"
      $stderr.flush

      da = DependencyAnalyzer.new( file )

      FileUtils.copy( file, DROP_DIR )

      rootname = File.join(DROP_DIR,File.basename(file).fun3d_clean.sub(/\.f90$/i,''))

      File.open(rootname+'.txt',    'w'){ |f| f.puts da.summary }
      File.open(rootname+'_use.dot','w'){ |f| f.puts da.graph(da.use_deps) }
      File.open(rootname+'_lvl.dot','w'){ |f| f.puts da.graph(da.lvl_deps) }

      if dot_capable
        puts command = " dot -Tps #{rootname}_lvl.dot -o #{rootname}_lvl.ps" +
        " && epstopdf #{rootname}_lvl.ps"
        system command
        puts command = " dot -Tps #{rootname}_use.dot -o #{rootname}_use.ps" +
        " && epstopdf #{rootname}_use.ps"
        system command
      end

      root = File.basename(rootname)

      index.puts " <tr>"
      index.puts "  <td align=right>#{da.levels.size}</td>"
      index.puts "  <td align=right>#{da.components}</td>"
      index.puts "  <td align=right>#{da.ccd}</td>"
      index.puts "  <td align=right>#{sprintf('%.1f',da.acd)}</td>"
      index.puts "  <td align=right>#{sprintf('%.2f',da.nccd)}</td>"
      index.puts "  <td><a href='#{root}.txt'>(details)</a></td>"
      index.puts "  <td><a href='#{root}_use.dot'>dot</a>|" +
      "<a href='#{root}_use.ps'>PS</a>|" +
      "<a href='#{root}_use.pdf'>PDF</a></td>"
      index.puts "  <td><a href='#{root}_lvl.dot'>dot</a>|" +
      "<a href='#{root}_lvl.ps'>PS</a>|" +
      "<a href='#{root}_lvl.pdf'>PDF</a></td>"
      index.puts "  <td><a href='#{File.basename(file)}'>#{File.basename(file)}</a></td>"
      index.puts " </tr>"

    end

    if files.size > 20
      index.puts " <tr>"
      index.puts "  <th>Level</th>"
      index.puts "  <th>#Cs</th>"
      index.puts "  <th>CCD</th>"
      index.puts "  <th>ACD</th>"
      index.puts "  <th>NCCD</th>"
      index.puts "  <th></th>"
      index.puts "  <th>Use</th>"
      index.puts "  <th>Level</th>"
      index.puts "  <th align=left>Source</th>"
      index.puts " </tr>"
      index.puts " <tr>"
      index.puts "  <th colspan=5>Statistics</th>"
      index.puts "  <th></th>"
      index.puts "  <th colspan=2>Dependency Plots</th>"
      index.puts " </tr>"
    end

    index.puts "</table>"
    index.puts "</body>"
    index.puts "</html>"

  end

end
