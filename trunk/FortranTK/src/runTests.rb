def runTests testSuites

 sources = testSuites.join(".f90 ") + ".f90"
 tests   = testSuites.join("TS.f90 ") + "TS.f90"

 compile = "#{ENV['F9X']} -o TestRunner #{sources} #{tests} TestRunner.f90"

 if system(compile)
  system "./TestRunner" if File.exists? "TestRunner"
 else
  print "\nCompile failed.\n"
 end

end
