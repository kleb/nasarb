require 'runit/testcase'
require 'Asserts'
 
class AssertsUT < RUNIT::TestCase
 def setup
  @testSuiteName = "GasModel"
  @testName = "PointyPeeLives"
 end
 def testPublicMethodsAvailable
  asserts = ["IsEqual", "IsRealEqual", "IsEqualWithin", "IsFalse", "IsTrue"]
  assert_equal(Asserts.new(@testName,@testSuiteName).methods[0..4]-asserts,[])
 end
 def testAssertsExpand
  anAssert=Asserts.new(@testName,@testSuiteName)
  asserts=anAssert.methods[0..4]
  lines=["IsTrue(False)", "IsFalse(True)", "IsEqual(1+1,2)", "IsRealEqual(1.*2.,2.)", "IsEqualWithin(10,11,1)"]
  asserts.each do |assert|
   anAssert.send "#{assert}", " IsFalse(True)",  $.
  end
 end
end

if $0 == __FILE__ then
 require 'runit/cui/testrunner'
 RUNIT::CUI::TestRunner.run(AssertsUT.suite)
end
