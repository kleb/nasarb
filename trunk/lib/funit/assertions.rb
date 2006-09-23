# Define Fortran assertion macros
#--
# Copyright 2006 United States Government as represented by
# NASA Langley Research Center. No copyright is claimed in
# the United States under Title 17, U.S. Code. All Other Rights
# Reserved.
#
# This file is governed by the NASA Open Source Agreement.
# See COPYING for details.
#++

# An argument scanner thanks to James Edward Gray II
# by way of ruby-talk mailing list

require 'strscan'

class String
  def get_args
    scanner = StringScanner.new(self)
    result  = scanner.eos? ? Array.new : ['']
    paren_depth = 0
    until scanner.eos?
      if scanner.scan(/[^(),]+/)
        # do nothing--we found the part of the argument we need to add
      elsif scanner.scan(/\(/)
        paren_depth += 1
      elsif scanner.scan(/\)/)
        paren_depth -= 1
      elsif scanner.scan(/,\s*/) and paren_depth.zero?
        result << ""
        next
      end

      result.last << scanner.matched
    end
    result
  end
end

module Funit
  module Assertions

    $assertRegEx = /Is(RealEqual|False|True|EqualWithin|Equal)\(.*\)/i

    def istrue(line)
      line.match(/\((.+)\)/)
      @type = 'IsTrue'
      @condition = ".not.(#$1)"
      @message = "\"#$1 is not true\""
      syntaxError("invalid body for #@type",@suiteName) unless $1=~/\S+/
      writeAssert
    end

    def isfalse(line)
      line.match(/\((.+)\)/)
      @type = 'IsFalse'
      @condition = "#$1"
      @message = "\"#$1 is not false\""
      syntaxError("invalid body for #@type",@suiteName) unless $1=~/\S+/
      writeAssert
    end

    def isrealequal(line)
      line.match(/\((.*)\)/)
      expected, actual = *($1.get_args)
      @type = 'IsRealEqual'
      @condition = ".not.(#{expected}+2*spacing(real(#{expected})).ge.#{actual} &\n             .and.#{expected}-2*spacing(real(#{expected})).le.#{actual})"
      @message = "\"#{actual} (\",#{actual},\") is not\",#{expected},\"within\",2*spacing(real(#{expected}))"
      syntaxError("invalid body for #@type",@suiteName) unless $&
      writeAssert
    end

    def isequalwithin(line)
      line.match(/\((.*)\)/)
      expected, actual, tolerance = *($1.get_args)
      @type = 'IsEqualWithin'
      @condition = ".not.(#{actual}+#{tolerance}.ge.#{expected} &\n             .and.#{actual}-#{tolerance}.le.#{expected})"
      @message = "\"#{expected} (\",#{expected},\") is not\",#{actual},\"within\",#{tolerance}"
      syntaxError("invalid body for #@type",@suiteName) unless $&
      writeAssert
    end

    def isequal(line)
      line.match(/\((\w+\(.*\)|[^,]+),(.+)\)/)
      @type = 'IsEqual'
      @condition = ".not.(#$1==#$2)"
      @message = "\"#$1 (\",#$1,\") is not\", #$2"
      syntaxError("invalid body for #@type",@suiteName) unless $&
      writeAssert
    end

    def writeAssert
      <<-OUTPUT
  ! #@type assertion
  numAsserts = numAsserts + 1
  if (noAssertFailed) then
    if (#@condition) then
      print *, " *#@type failed* in test #@testName &
              &[#{@suiteName}.fun:#{@lineNumber.to_s}]"
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

  end # module Assertions
end # module Funit
