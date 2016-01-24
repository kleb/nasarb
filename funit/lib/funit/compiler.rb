module Funit

  ##
  # Fortran compiler

  class Compiler

    def initialize
      error_message = <<-COMPILER
Fortran compiler environment variable 'FC' not set.

For example, if you had the g95 compiler:

      sh: export FC=g95
     csh: setenv FC g95
 windows: set FC=C:\\Program Files\\g95
      COMPILER
      raise error_message unless ENV['FC']
    end

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
