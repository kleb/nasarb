module Funit
  class C_compile
    def initialize
      check_c_compiler
      @libraries = {}
    end
   
    def check_c_compiler
      if(ENV['CXX'].nil?) then
        puts <<-EOF
        
          You have not specified a C++ compiler. Please specify a compiler via the $(CXX) environment variable.
          
          In bash, for example:
            
            export CXX="g++"
  
        EOF
      elsif(ENV['CC'].nil?) then
        puts <<-EOF
        
          You have not specified a C compiler. Please specify a compiler via the $(CC) environment variable.
          
          In bash, for example:
            
            export CC="gcc"
            
        EOF
      exit
      end
    end
     
    def compile_library(dir)
      puts "building: #{dir}"
      Dir.chdir(dir) do
        static_lib = make_objs
        @libraries[dir]=static_lib.match(/lib(\w+)\.a/).captures.join
      end
    end
    
    def make_objs(dir=Dir.getwd)
      if File.exist?("Makefile.am")
        sources = parse_automake_file
        static_library = sources[0]
        File.open("makeTestRunner", "w") {|file| file.puts write_custom_c_makefile(sources)}
      else
				static_library = "lib#{File.basename(Dir.getwd)}.a"
        File.open("makeTestRunner", "w") {|file| file.puts write_generic_c_makefile(static_library)}
      end
      compile = "make -f makeTestRunner"
      raise "Compile failed in #{dir}." unless system compile
      static_library
    end
   
    def parse_automake_file
      sources = []
      lines = IO.readlines("Makefile.am")
      while line = lines.shift
        sources << $1 if line.match(/^\s*lib_LIBRARIES\s*=\s*(\w+\.a)/)
        if line.match(/^\s*\w+_SOURCES\s*=/)
          sources << line.scan(/\w+\.cpp/)
          while line.match(/\\\s*$/)
            line = lines.shift
            sources << line.scan(/(\w+\.cpp)|(\w+\.c)/)
          end
        end
      end
      sources.uniq.flatten.compact
    end
   
    def print_linker_flags
      output_string = ''
      @libraries.each do |k,v|
        output_string += " -L#{k} -l#{v}"
      end
      output_string += " -lstdc++"
    end
    
    def clean_c_code
      @libraries.keys.each do |k| 
        Dir.chdir(k) do
          puts "cleaning C code in #{k}"
          make_clean = "make -f makeTestRunner clean"
          system make_clean
          FileUtils.rm "makeTestRunner"
        end
      end
    end
     
    def write_generic_c_makefile(library)
      c_makefile = %Q{
      # makefile to compile c++ code
      # Add .d to Make's recognized suffixes.
      SUFFIXES += .d
      
      #Archive command and options 
      AR = ar
      AR_OPTS = cru
       
      LIBRARY = #{library}
       
      #We don't need to clean up when we're making these targets
      NODEPS:=clean tags svn
      #Find all the C++ files in this directory
      SOURCES:=$(shell find . -name "*.cpp")
      SOURCES+=$(shell find . -name "*.c")
      
      #These are the dependency files, which make will clean up after it creates them
      CFILES:=$(SOURCES:.cpp=.c)
      DEPFILES:=$(CFILES:.c=.d)
   
      OBJS:=$(CFILES:.c=.o)
      
      all: $(LIBRARY)
      
      #Rule to create library archive 
      $(LIBRARY): $(OBJS)
      \t$(AR) $(AR_OPTS) $@ $^
    
      #Don't create dependencies when we're cleaning, for instance
      ifeq (0, $(words $(findstring $(MAKECMDGOALS), $(NODEPS))))
          #Chances are, these files don't exist.  GMake will create them and
          #clean up automatically afterwards
          -include $(DEPFILES)
      endif
    
      #This is the rule for creating the C++ dependency files
      %.d: %.cpp
      \t$(CXX) $(CXXFLAGS) -MM -MT '$(patsubst %.cpp,%.o,$<)' $< -MF $@
      
      #This is the rule for creating the C dependency files
      %.d: %.c
      \t$(CC) $(CFLAGS) -MM -MT '$(patsubst %.c,%.o,$<)' $< -MF $@
      
      #This rule does the compilation for C++ files
      %.o: %.cpp %.d %.h
      \t$(CXX) $(CXXFLAGS) -o $@ -c $<
      
      #This rule does the compilation for C files
      %.o: %.c %.d %.h
      \t$(CC) $(CFLAGS) -o $@ -c $<
      
      clean:
      \trm -rf *.o *.d *.a
    
      }.gsub!(/^      /,'')
    end
    
    def write_custom_c_makefile(sources)
      library = sources.shift
      source_files = sources.join(" ")
      c_makefile = %Q{
      # makefile to compile c++ code
      # Add .d to Make's recognized suffixes.
      SUFFIXES += .d
 
      #Archive command and options 
      AR = ar
      AR_OPTS = cru
       
      LIBRARY = #{library}
       
      SOURCES = #{source_files}
      
      #These are the dependency files, which make will clean up after it creates them
      CFILES:=$(SOURCES:.cpp=.c)
      DEPFILES:=$(CFILES:.c=.d)
 
      OBJS:=$(CFILES:.c=.o)
      
      all: $(LIBRARY)
     
      #Rule to create library archive 
      $(LIBRARY): $(OBJS)
      \t$(AR) $(AR_OPTS) $@ $^
      
      #Don't create dependencies when we're cleaning, for instance
      ifeq (0, $(words $(findstring $(MAKECMDGOALS), $(NODEPS))))
          #Chances are, these files don't exist.  GMake will create them and
          #clean up automatically afterwards
          -include $(DEPFILES)
      endif
    
      #This is the rule for creating the C++ dependency files
      %.d: %.cpp
      \t$(CXX) $(CXXFLAGS) -MM -MT '$(patsubst %.cpp,%.o,$<)' $< -MF $@
      
      #This is the rule for creating the C dependency files
      %.d: %.c
      \t$(CC) $(CFLAGS) -MM -MT '$(patsubst %.c,%.o,$<)' $< -MF $@
      
      #This rule does the compilation for C++ files
      %.o: %.cpp %.d %.h
      \t$(CXX) $(CXXFLAGS) -o $@ -c $<
      
      #This rule does the compilation for C files
      %.o: %.c %.d %.h
      \t$(CC) $(CFLAGS) -o $@ -c $<
      
      clean:
      \trm -rf *.o *.d *.a
      }.gsub!(/^      /,'')
    end
  end
end
