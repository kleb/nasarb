# extend Array with some randomized versions of stock functions

class Array # FIXME: monkey patch

  def rand_sort
    self.sort{ |a,b| rand < 0.5 ? -1 : 1 }
  end

  def rand_zip(other)
    (self.rand_sort).zip(other.rand_sort)
  end

end

module Uq4sim

  def interval_samples( num_of_intervals )
    p = []
    1.upto(num_of_intervals) do |i|
      p << rand/num_of_intervals + Float(i-1)/num_of_intervals
    end
    p
  end

end
