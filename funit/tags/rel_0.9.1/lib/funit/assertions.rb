require 'strscan'

module Funit
  
  ##
  # Fortran assertion macro definitions

  module Assertions

    def istrue(line)
      line.match(/\((.+)\)/)
      @type = 'IsTrue'
      @condition = ".not.(#$1)"
      @message = "\"#$1 is not true\""
      syntax_error("invalid body for #@type",@suite_name) unless $1=~/\S+/
      write_assert
    end

    def isfalse(line)
      line.match(/\((.+)\)/)
      @type = 'IsFalse'
      @condition = "#$1"
      @message = "\"#$1 is not false\""
      syntax_error("invalid body for #@type",@suite_name) unless $1=~/\S+/
      write_assert
    end

    def isrealequal(line)
      line.match(/\((.*)\)/)
      expected, actual = *(get_args($1))
      @type = 'IsRealEqual'
      @condition = ".not.(#{expected}+2*spacing(real(#{expected})).ge.#{actual} &\n             .and.#{expected}-2*spacing(real(#{expected})).le.#{actual})"
      @message = "\"#{actual} (\",#{actual},\") is not\",#{expected},\"within\",2*spacing(real(#{expected}))"
      syntax_error("invalid body for #@type",@suite_name) unless $&
      write_assert
    end

    def isequalwithin(line)
      line.match(/\((.*)\)/)
      expected, actual, tolerance = *(get_args($1))
      @type = 'IsEqualWithin'
      @condition = ".not.(#{actual}+#{tolerance}.ge.#{expected} &\n             .and.#{actual}-#{tolerance}.le.#{expected})"
      @message = "\"#{expected} (\",#{expected},\") is not\",#{actual},\"within\",#{tolerance}"
      syntax_error("invalid body for #@type",@suite_name) unless $&
      write_assert
    end

    def isequal(line)
      line.match(/\((\w+\(.*\)|[^,]+),(.+)\)/)
      @type = 'IsEqual'
      @condition = ".not.(#$1==#$2)"
      @message = "\"#$1 (\",#$1,\") is not\", #$2"
      syntax_error("invalid body for #@type",@suite_name) unless $&
      write_assert
    end
    
    ##
    # An argument scanner thanks to James Edward Gray II
    # by way of ruby-talk mailing list.

    def get_args(string)
      scanner = ::StringScanner.new(string)
      result  = scanner.eos? ? [] : ['']
      paren_depth = 0
      until scanner.eos?
        if scanner.scan(/[^(),]+/)
          # do nothing--we found the part of the argument we need to add
        elsif scanner.scan(/\(/)
          paren_depth += 1
        elsif scanner.scan(/\)/)
          paren_depth -= 1
        elsif scanner.scan(/,\s*/) and paren_depth.zero?
          result << ''
          next
        end
        result.last << scanner.matched
      end
      result
    end
    
    ##
    # Translate the assertion to Fortran.
    
    def write_assert
      <<-OUTPUT
  ! #@type assertion
  numAsserts = numAsserts + 1
  if (noAssertFailed) then
    if (#@condition) then
      print *, " *#@type failed* in test #@test_name &
              &[#{@suite_name}.fun:#{@line_number.to_s}]"
      print *, "  ", #@message
      print *, ""
      noAssertFailed = .false.
      numFailures    = numFailures + 1
    else
      numAssertsTested = numAssertsTested + 1
    endif
  endif
      OUTPUT
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