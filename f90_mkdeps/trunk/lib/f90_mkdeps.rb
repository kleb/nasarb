module F90
  
  ##
  # Find Fortran file dependencies

  class MakeDeps

    VERSION = '1.0.0'
 
    OPTIONS = { :search_paths => [ '.', '../lib' ],
                :ignore_files => %r{ },
                :ignore_modules => %r{ },
                :ignore_symlinks => true }
    
    USE_MODULE_REGEX = /^\s*use\s+(\w+)/i
    MODULE_DEF_REGEX = /^\s*module\s+(\w+)/i
 
    FILE_EXTENSION = /\.f90$/i
  
    attr_reader :file_dependencies, :source_files

    def initialize( config=OPTIONS )
      @config = config
      OPTIONS.each{ |opt,default| @config[opt] = default unless @config.has_key? opt }
      @parsed, @file_dependencies, @source_files = [], {}, []
      @hash = build_hash_of_modules_in_files
    end

    def modules_used_in( file )
      modules = IO.readlines( file ).map do |line|
        $1.downcase if line.match USE_MODULE_REGEX
      end.uniq.compact
    end

    def modules_defined_in( file )
      modules = IO.readlines( file ).map do |line| 
        $1.downcase if line.match MODULE_DEF_REGEX
      end.uniq.compact
    end

    def build_dictionary_of_modules( files )
      file_containing_module = {}
      files.each do |file|
        modules_defined_in( file ).each{ |mod| file_containing_module[mod]=file }
      end
      file_containing_module
    end

    def find_fortran_files
      source = @config[:search_paths].map{ |path| Dir[path+"/*.[fF]90"] }
      source.flatten!.uniq!
      source.delete_if{ |file| File.lstat(file).symlink? } if @config[:ignore_symlinks]
      source.delete_if{ |file| file.match @config[:ignore_files] }
    end

    def build_hash_of_modules_in_files
      build_dictionary_of_modules find_fortran_files
    end

    def makefile_dependency_line( source )
      real_source = source.sub(/PHYSICS_DUMMY/,'PHYSICS_MODULES')# FIXME: What's this?!
      source_no_path = File.basename source
      @source_files.push source_no_path.gsub(%r|^.*/|,'')
      output = ''
      if (File.expand_path(source) != File.expand_path(source_no_path))
        output += source_no_path+ ": " + real_source + "\n"
        output += "\tln -sf "+real_source+" .\n"
      end
      output += source.gsub(FILE_EXTENSION, ".o").gsub(%r|^.*/|,'' ) +
                ": " + source.gsub(%r|^.*/|,"" ) 
      modules_used_in( source ).each do |use|
        unless @hash[use]
          unless use.match @config[:ignore_modules]
            $stderr.puts 'Warning: unable to locate module #{use} used in #{source}.'
            $stderr.puts '         set :search_paths or :ignore_module_regex options.'
          end
          next
        end
        output = output + " \\\n " +
                 @hash[use].gsub(FILE_EXTENSION, ".o").gsub(%r|^.*/|,'' )
      end
      output+"\n"
    end

    def dependencies( start )
      modules = modules_used_in( start )
      @parsed = @parsed || [start]
      new_source_files = modules.collect{ |mod| @hash[mod] }.compact
      makefile_dependency_line(start) +
      new_source_files.collect do |file|
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
      sources = []
      until @file_dependencies.empty? do
        no_dependents_pair = @file_dependencies.detect{ |h,d| d == [] }
        no_dependents = no_dependents_pair.first
        sources.push no_dependents
        @file_dependencies.delete(no_dependents){ |el| "#{el} not found" }
        @file_dependencies.each_value{ |deps| deps.delete(no_dependents) }
      end
      sources
    end

  end
end

#--
# Copyright 2007 United States Government as represented by
# NASA Langley Research Center. No copyright is claimed in
# the United States under Title 17, U.S. Code. All Other Rights
# Reserved.
#
# This file is governed by the NASA Open Source Agreement.
# See License.txt for details.
#++