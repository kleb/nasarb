require 'test/unit'
require 'uq4sim/latin_hypercube_samples'

class TestLatinHypercubeSamples < Test::Unit::TestCase

  include Uq4sim

  def setup
    srand 1234 # make random sequence repeatable
  end

  def test_rand_sort
    x = [1,2,3,4]
    assert_equal( [1,4,3,2], x.rand_sort )
  end

  def test_rand_zip
    x = [ :a, :b, :c, :d ]
    y = [ 1, 2, 3, 4 ]
    assert_equal( [[:a,1],[:d,3],[:c,4],[:b,2]], x.rand_zip(y) )
  end

  def test_interval_samples
    100.times do
      p = interval_samples(5)
      assert( (0.0..0.2).include?(p[0]) )
      assert( (0.2..0.4).include?(p[1]) )
      assert( (0.4..0.6).include?(p[2]) )
      assert( (0.6..0.8).include?(p[3]) )
      assert( (0.8..1.0).include?(p[4]) )
    end
  end

end
