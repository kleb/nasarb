# Find Fortran dependencies
#--
# This scripts finds dependencies for f90 code
# Copyright 2006 United States Government as represented by
# NASA Langley Research Center. No copyright is claimed in
# the United States under Title 17, U.S. Code. All Other Rights
# Reserved.
#
# This file is governed by the NASA Open Source Agreement.
# See COPYING for details.
#++

raise "Need Ruby version >= 1.8, current using #{VERSION}" \
 unless String.instance_methods.include? "match"

module Funit

  class Depend

    attr_reader :file_dependencies, :source_files

    def initialize( searchPath = %w[ ../lib . ] )
      @parsed = Array.new
      @hash = build_hash_of_modules_in_files_within searchPath
      @file_dependencies = Hash.new
      @source_files = Array.new
    end

    def modules_used_in( file )
      modules = IO.readlines( file ).map do |line|
        $1.downcase if line.match( /^\s*use\s+(\w+)/i )
      end.uniq.compact
    end

    def modules_defined_in( file )
      modules = IO.readlines( file ).map do |line| 
        $1.downcase if line.match( /^\s*module\s+(\w+)/i )
      end.uniq.compact
    end

    def build_dictionary_of_modules_in( files )
      file_containing_module = Hash.new
      files.each do |file|
        modules_defined_in( file ).each{ |mod| file_containing_module[mod]=file }
      end
      file_containing_module
    end

    def fortran_files_within( search_path = %w[ ../lib . ] )
      source = search_path.map{ |path| Dir[path+"/*.[fF]90"] }
      source.flatten!.uniq!
      source.delete_if{ |file| File.lstat(file).symlink? }
      source.delete_if{ |file| file.match(/lmpi_module_template.F90/) }
    end

    def build_hash_of_modules_in_files_within( searchPath = %w[../lib .] )
      build_dictionary_of_modules_in( fortran_files_within( searchPath ) )
    end

    def makefile_dependency_line( source )
      realSource = source.sub(/PHYSICS_DUMMY/,'PHYSICS_MODULES')# What's this?
      sourceNoPath = File.basename source
      @source_files.push sourceNoPath.gsub(%r|^.*/|,'')
      output = ''
      if (File.expand_path(source) != File.expand_path(sourceNoPath))
        output += sourceNoPath+ ": " + realSource + "\n"
        output += "\tln -sf "+realSource+" .\n"
      end
      output += source.gsub(/\.(f|F)90$/, ".o").gsub(%r|^.*/|,"" ) +
                ": " + source.gsub(%r|^.*/|,"" ) 
      modules_used_in( source ).each do |use|
        unless @hash[use]
          unless ( use=~/f90_unix/ || use=~/nas_system/ )
            $stderr.puts "Warning: unable to locate module #{use} used in #{source}." if $DEBUG
          end
          next
        end
        output = output + " \\\n " +
                 @hash[use].gsub(/\.(f|F)90$/, ".o").gsub(%r|^.*/|,"" )
      end
      output+"\n"
    end

    def dependencies( start )
      modules = modules_used_in( start )
      @parsed = @parsed || [start]
      newSourceFiles = modules.collect{ |mod| @hash[mod] }.compact
      makefile_dependency_line(start) +
      newSourceFiles.collect do |file|
        next if @parsed.include?(file)
        @parsed.push file
        dependencies file
      end.to_s
    end

    def source_file_dependencies( head_f90 )
      modules_head_uses = modules_used_in( head_f90 )
      required_f90s = modules_head_uses.map{ |mod| @hash[mod] }.compact
      @file_dependencies[head_f90] = required_f90s
      required_f90s.each do |required_f90|
        next if @parsed.include?(required_f90)
        source_file_dependencies( required_f90 )
      end
      @parsed.push head_f90
    end

    def required_source_files( head_f90 )
      @parsed.clear
      source_file_dependencies( head_f90 )
      sources = Array.new
      while ! @file_dependencies.empty? do
        no_dependents_pair = @file_dependencies.detect{ |h,d| d == [] }
        no_dependents = no_dependents_pair.first
        sources.push no_dependents
        @file_dependencies.delete(no_dependents){ |el| "#{el} not found" }
        @file_dependencies.each_value{ |deps| deps.delete(no_dependents) }
      end
      sources
    end

  end # class

end # module
