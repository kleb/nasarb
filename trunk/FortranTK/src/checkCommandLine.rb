def checkCommandLineFor allTestSuites

 return allTestSuites if $*.empty?

 testSuitesNotFound = $* - ( $* & allTestSuites )
 if testSuitesNotFound.empty?
  return $*
 else
  print "\n Error: could not find test suite:"
  testSuitesNotFound.each {|testSuiteNotFound| print " #{testSuiteNotFound}"}
  print "\n\n Test suites available in this directory:\n"
  allTestSuites.each { |testSuite| print "  #{testSuite}\n" }
  print "\nUsage: #{File.basename $0} [test names (w/o TS.ftk suffix)]\n\n"
  exit 1
 end

end
