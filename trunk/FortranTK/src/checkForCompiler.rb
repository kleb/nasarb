
def checkForCompiler
 unless ENV['F9X']
  puts <<-ENVIRON

Fortran compiler environment variable 'F9X' not set:

 for bourne-based shells: export F9X=lf95 (in .profile)
      for c-based shells: setenv F9X lf95 (in .login)
             for windows: set F9X=C:\Program Files\lf95 (in autoexec.bat)

  ENVIRON
  exit 1
 end
end
