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
  # An inverse normal cumulative distribution approximation
  # from http://home.online.no/~pjacklam/notes/invnorm/

  def inverse_normal_cdf( p )
    raise "p must be between 0 and 1; received: #{p}" if p <= 0 or p >= 1
    a = [ -3.969683028665376e+01,  2.209460984245205e+02,
          -2.759285104469687e+02,  1.383577518672690e+02,
          -3.066479806614716e+01,  2.506628277459239e+00 ]
    b = [ -5.447609879822406e+01,  1.615858368580409e+02,
          -1.556989798598866e+02,  6.680131188771972e+01,
          -1.328068155288572e+01 ]
    c = [ -7.784894002430293e-03, -3.223964580411365e-01,
          -2.400758277161838e+00, -2.549732539343734e+00,
           4.374664141464968e+00,  2.938163982698783e+00 ]
    d = [  7.784695709041462e-03,  3.224671290700398e-01,
           2.445134137142996e+00,  3.754408661907416e+00 ]
    case p
    when 0..0.02425
      q = Math.sqrt(-2*Math.log(p))
      (((((c[0]*q+c[1])*q+c[2])*q+c[3])*q+c[4])*q+c[5]) /
      ((((d[0]*q+d[1])*q+d[2])*q+d[3])*q+1)
    when 0.97575..1
      q = Math.sqrt(-2*Math.log(1-p))
      -(((((c[0]*q+c[1])*q+c[2])*q+c[3])*q+c[4])*q+c[5]) /
      ((((d[0]*q+d[1])*q+d[2])*q+d[3])*q+1)
    else
      q = p - 0.5
      r = q**2
      (((((a[0]*r+a[1])*r+a[2])*r+a[3])*r+a[4])*r+a[5])*q /
      (((((b[0]*r+b[1])*r+b[2])*r+b[3])*r+b[4])*r+1)
    end
  end

end
