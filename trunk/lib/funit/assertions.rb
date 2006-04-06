module Funit
  module Assertions

    $assertRegEx = /Is(RealEqual|False|True|EqualWithin|Equal)\(.*\)/i

    def istrue(line)
      line=~/\((.+)\)/
      @type = 'IsTrue'
      @condition = ".not.(#$1)"
      @message = "\"#$1 is not true\""
      syntaxError("invalid body for #@type",@suiteName) unless $1=~/\S+/
        writeAssert
    end

    def isfalse(line)
      line=~/\((.+)\)/
      @type = 'IsFalse'
      @condition = "#$1"
      @message = "\"#$1 is not false\""
      syntaxError("invalid body for #@type",@suiteName) unless $1=~/\S+/
        writeAssert
    end

    def isrealequal(line)
      line=~/\(([^,]+),(.+)\)/
      @type = 'IsRealEqual'
      @condition = ".not.(#$1+2*spacing(real(#$1)).ge.#$2 &\n             .and.#$1-2*spacing(real(#$1)).le.#$2)"
      @message = "\"#$2 (\",#$2,\") is not\",#$1,\"within\",2*spacing(real(#$1))"
      syntaxError("invalid body for #@type",@suiteName) unless $&
      writeAssert
    end

    def isequalwithin(line)
      line=~/\(([^,]+),(.+),(.+)\)/
      @type = 'IsEqualWithin'
      @condition = ".not.(#$2+#$3.ge.#$1 &\n             .and.#$2-#$3.le.#$1)"
      @message = "\"#$1 (\",#$1,\") is not\",#$2,\"within\",#$3"
      syntaxError("invalid body for #@type",@suiteName) unless $&
      writeAssert
    end

    def isequal(line)
      line=~/\((\w+\(.*\)|[^,]+),(.+)\)/
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
                         &[#{@suiteName}MT.ftk:#{@lineNumber.to_s}]"
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
