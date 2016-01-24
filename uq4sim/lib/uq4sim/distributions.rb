module Uq4sim

  ##
  # Return a random number drawn from a normal distribution
  # with mean 0 and standard deviation sigma, which defaults
  # to 1 if not provided.  The normal distribution approximation
  # is from Abramowitz and Stegun.

  def randn( sigma=1.0 )
    r = rand
    if r < 0.5
      t = Math.sqrt(Math.log(1.0/r**2))
      x = t - (2.515517 + 0.802853*t + 0.010328*t**2) /
      (1.0 + 1.432788*t + 0.189269*t**2 + 0.001308*t**3)
    else # reflect for symmetry
      t = Math.sqrt(Math.log(1.0/(1-r)**2))
      x = -t + (2.515517 + 0.802853*t + 0.010328*t**2) /
      (1.0 + 1.432788*t + 0.189269*t**2 + 0.001308*t**3)
    end
    x*sigma
  end

  ##
  # Return a random number drawn from a uniform distribution
  # centered on 0 of a given halfwidth, which defaults to 0.5.

  def randu( halfwidth=0.5 )
    (rand-0.5)*halfwidth*2
  end
  
  ##
  # Return a random number drawn from a symmertrical
  # triangular distribution centered on 0 of a given
  # halfwidth, which defaults to 0.5.
  
  def randt( halfwidth=0.5 )
    left, right, peak = -halfwidth, halfwidth, 0.0
    x = rand
    if x < (peak-left)/(right-left)
      left  + Math.sqrt( (  x)*(right-left)*( peak-left)  )
    else
      right - Math.sqrt( (1-x)*(right-left)*(right-peak) )
    end
  end

end
