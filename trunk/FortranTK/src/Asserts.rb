class Asserts
 def initialize(testName, testSuiteName)
  @testName, @testSuiteName = testName, testSuiteName
 end
 def IsRealEqual(line, lineNumber)
  line =~ /(IsRealEqual)\s*\((.*),(.*)\)/
  condition = ".not.(#$3+2*spacing(real(#$3)).ge.#$2.and.#$3-2*spacing(real(#$3)).le.#$2)"
  message = "#$2,\"is not\",#$3,\"within\",2*spacing(real(#$3))"
  expandAssert( $1, condition, message, lineNumber )
 end
 def IsEqualWithin(line, lineNumber)
  line =~ /(IsEqualWithin)\s*\((.*),(.*),(.*)\)/
  condition = ".not.(#$3+#$4.ge.#$2.and.#$3-#$4.le.#$2)"
  message = "#$2,\"is not\",#$3,\"within\",#$4"
  expandAssert( $1, condition, message, lineNumber )
 end
 def IsEqual(line, lineNumber)
  line =~ /(IsEqual)\s*\((.*),(.*)\)/
  condition = ".not.(#$2==#$3)"
  message = "#$2, \"is not\", #$3"
  expandAssert( $1, condition, message, lineNumber )
 end
 def IsTrue(line, lineNumber)
  line =~ /(IsTrue)\s*\((.*)\)/
  condition = ".not.(#$2)"
  message = "#$2, \"is not true\""
  expandAssert( $1, condition, message, lineNumber )
 end
 def IsFalse(line, lineNumber)
  line =~ /(IsFalse)\s*\((.*)\)/
  condition = "#$2"
  message = "#$2, \"is not false\""
  expandAssert( $1, condition, message, lineNumber )
 end
 private
 def expandAssert( assertName, condition, message, lineNumber )
  puts "\n  ! #{assertName} assertion"
  puts "  numAsserts = numAsserts + 1"
  puts "  if (noAssertFailed) then"
  puts "   if (#{condition}) then"
  puts "    print *, \"  FAILURE: #{assertName} in test #{@testName} " \
                        "(Line #{lineNumber} of #{@testSuiteName}TS.ftk)\""
  puts "    print *, \"   \", #{message}"
  puts "    noAssertFailed = .false."
  puts "    numFailures    = numFailures + 1"
  puts "   else"
  puts "    numAssertsTested = numAssertsTested + 1"
  puts "   endif"
  puts "  endif"
 end
end
