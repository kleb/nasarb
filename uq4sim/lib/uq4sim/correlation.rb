require 'uq4sim/enumerable_sum'

module Uq4sim

  ##
  # Returns an array with correlation and y-normalized correlation^2
  # Assumes two nested arrays of variables and samples.  For example,
  # here's a case with 3 samples of 3 input variables and 2 output variables:
  #
  #   x = [ [a1,a2,a3], [b1,b2,b3], [c1,c2,c3] ]
  #   y = [ [r1,r2,r3], [s1,s2,s3] ]

  def correlation(x,y)

    fail 'size arrays unequal'  if x.first.size != y.first.size # FIXME: make stronger!!

    n = x.first.size

    sum_x    = x.map{ |xi| xi.sum }
    sum_y    = y.map{ |yi| yi.sum }

    sum_x_sq = x.map{ |xi| xi.map{ |e| e**2 }.sum }
    sum_y_sq = y.map{ |yi| yi.map{ |e| e**2 }.sum }

    sum_xy = x.map do |xi|
      y.map do |yj|
        xi.zip(yj).inject(0){ |sum,xy| sum + xy.first*xy.last }
      end
    end

    corr = Array.new(x.size){ Array.new(y.size){0.0} }
    for i in 0...x.size
      for j in 0...y.size
        dx = n*sum_x_sq[i] - sum_x[i]**2
        dy = n*sum_y_sq[j] - sum_y[j]**2
        corr[i][j] = ( n*sum_xy[i][j] - sum_x[i]*sum_y[j] ) / Math.sqrt(dx*dy) unless dx*dy==0.0
      end
    end

    sum_corr_sq_y = Array.new(y.size){0.0}
    for j in 0...y.size
      for i in 0...x.size
        sum_corr_sq_y[j] += corr[i][j]**2
      end
    end

    corr_sq = Array.new(x.size){ Array.new(y.size){0.0} }
    for i in 0...x.size
      for j in 0...y.size
        corr_sq[i][j] = corr[i][j]**2/sum_corr_sq_y[j] unless sum_corr_sq_y[j]==0.0
      end
    end

    [corr, corr_sq]

  end

end
