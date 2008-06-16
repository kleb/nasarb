require 'lib/uq4sim/ltqnorm'

module Math
  # Inverse error function.
  def erfinv(x)
    ltqnorm(0.5*(x+1))/sqrt(2) # map domain from (-1,1) to (0,1) and scale
  end
  module_function :erfinv
end
