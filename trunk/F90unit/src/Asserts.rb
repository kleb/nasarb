module Asserts

 $assertRegEx = /Is(RealEqual|False|True|EqualWithin|Equal)\(.*\)/i

 def istrue(line)
  line=~/\((.+)\)/
  @type = 'IsTrue'
  @condition = ".not.(#$1)"
  @message = "\"#$1 is not true\""
  syntaxError("invalid body for #@type",@testSuite) unless $1=~/\S+/
  writeAssert
 end

 def isfalse(line)
  line=~/\((.+)\)/
  @type = 'IsFalse'
  @condition = "#$1"
  @message = "\"#$1 is not false\""
  syntaxError("invalid body for #@type",@testSuite) unless $1=~/\S+/
  writeAssert
 end

 def isrealequal(line)
  line=~/\((.+),(.+)\)/
  @type = 'IsRealEqual'
  @condition = ".not.(#$2+2*spacing(real(#$2)).ge.#$1 &\n             .and.#$2-2*spacing(real(#$2)).le.#$1)"
  @message = "\"#$1 (\",#$1,\") is not\",#$2,\"within\",2*spacing(real(#$2))"
  syntaxError("invalid body for #@type",@testSuite) unless $&
  writeAssert
 end

 def isequalwithin(line)
  line=~/\((.+),(.+),(.+)\)/
  @type = 'IsEqualWithin'
  @condition = ".not.(#$2+#$3.ge.#$1 &\n             .and.#$2-#$3.le.#$1)"
  @message = "\"#$1 (\",#$1,\") is not\",#$2,\"within\",#$3"
  syntaxError("invalid body for #@type",@testSuite) unless $&
  writeAssert
 end

 def isequal(line)
  line=~/\((.+),(.+)\)/
  @type = 'IsEqual'
  @condition = ".not.(#$1==#$2)"
  @message = "\"#$1 (\",#$1,\") is not\", #$2"
  syntaxError("invalid body for #@type",@testSuite) unless $&
  writeAssert
 end

 def writeAssert
  puts "\n  ! #@type assertion"
  puts "  numAsserts = numAsserts + 1"
  puts "  if (noAssertFailed) then"
  puts "   if (#@condition) then"
  puts "    print *, \" *#@type failed* in test #@testName &\n" \
  "                       &[#{@testSuite}TS.ftk:#$.]\""
  puts "    print *, \"  \", #@message"
  puts "    print *, \"\""
  puts "    noAssertFailed = .false."
  puts "    numFailures    = numFailures + 1"
  puts "   else"
  puts "    numAssertsTested = numAssertsTested + 1"
  puts "   endif"
  puts "  endif"
 end

end
