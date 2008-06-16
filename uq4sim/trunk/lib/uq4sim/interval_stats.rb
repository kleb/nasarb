#! /usr/bin/env ruby -ws

include Math

NUM_OF_VARIABLES = 4
CONFIDENCE_SIGMA = 2
confidence = erf(CONFIDENCE_SIGMA/sqrt(2))
NUM_OF_SAMPLES = (2/(1-confidence)**2).ceil

def y(x) ; x.inject(0){ |s,xi| s + xi } ; end

x0, dx = Array.new(NUM_OF_VARIABLES){ 1.0 }, Array.new(NUM_OF_VARIABLES){ 0.1 }

y0 = y(x0)

srand 1234 # rand seed to get repeatable, psuedo random numbers

c = []
1.upto(NUM_OF_SAMPLES) do |i|
  cauchy = Array.new(NUM_OF_VARIABLES){ tan(PI*(rand-0.5)) }
  cauchy_max = cauchy.max{ |a,b| a.abs <=> b.abs }
  xk = x0.zip(dx,cauchy).map{ |_x,_dx,_cauchy| _x + _dx*_cauchy/cauchy_max }
  c << (cauchy_max*(y(xk)-y0)).abs
end

delta_minus, delta_plus, delta_est = 0.0, c.max, 0.0
while delta_minus < 0.99*delta_plus do
  delta_est = 0.5*( delta_minus + delta_plus )
  sum = c.inject(0){ |acc,ci| acc + (delta_est**2)/(delta_est**2+ci**2) }
  sum < (NUM_OF_SAMPLES/2) ? delta_minus = delta_est : delta_plus = delta_est
end
delta_err = 2*delta_est*sqrt(2.0/NUM_OF_SAMPLES)
puts "estimated delta: %.3f +/- %.3f" % [delta_est, delta_err]

#puts "99%% bound for delta: %.3f" % [ delta_bound, delta_err]
