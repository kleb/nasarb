module Asserts

 $assertRegEx = /Is(RealEqual|Equal|False|True|EqualWithin)\(.*\)/

 def IsTrue(line)
  line=~/\((.+)\)/
  @type = 'IsTrue'
  @condition = ".not.(#$1)"
  @message = "\"#$1 is not true\""
  writeAssert
 end

 def IsRealEqual(line)
  line=~/\((.+),(.+)\)/
  @type = 'IsRealEqual'
  @condition = ".not.(#$2+2*spacing(real(#$2)).ge.#$1 &\n             .and.#$2-2*spacing(real(#$2)).le.#$1)"
  @message = "\"#$1 is not\",#$2,\"within\",2*spacing(real(#$2))"
  writeAssert
 end

 def IsEqualWithin(line)
  line=~/\((.+),(.+),(.+)\)/
  @type = 'IsEqualWithin'
  @condition = ".not.(#$2+#$3.ge.#$1 &\n             .and.#$2-#$3.le.#$1)"
  @message = "\"#$1 is not\",#$2,\"within\",#$3"
  writeAssert
 end

 def IsEqual(line)
  line=~/\((.+),(.+)\)/
  @type = 'IsEqual'
  @condition = ".not.(#$1==#$2)"
  @message = "\"#$1 is not\", #$2"
  writeAssert
 end

 def IsFalse(line)
  line=~/\((.+)\)/
  @type = 'IsFalse'
  @condition = "#$1"
  @message = "\"#$1 is not false\""
  writeAssert
 end

 def writeAssert
  puts "\n  ! #@type assertion"
  puts "  numAsserts = numAsserts + 1"
  puts "  if (noAssertFailed) then"
  puts "   if (#{@condition}) then"
  puts "    print *, \" FAILURE: #@type in test #{@testName} &\n" \
       "                       &(Line #$. of #{@testSuite}TS.ftk)\""
  puts "    print *, \"   \", #@message"
  puts "    noAssertFailed = .false."
  puts "    numFailures    = numFailures + 1"
  puts "   else"
  puts "    numAssertsTested = numAssertsTested + 1"
  puts "   endif"
  puts "  endif"
 end

end
