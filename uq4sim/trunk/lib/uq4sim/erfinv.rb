require 'ltqnorm'

module Math
  # Inverse error function.
  def erfinv(x)
    ltqnorm(0.5*(x+1))/sqrt(2) # map domain from (-1,1) to (0,1) and scale
  end
  module_function :erfinv
end

if $0 == __FILE__ then
  require 'test/unit'
  class TestMathErfinv < Test::Unit::TestCase
    include Math
    def test_should_reject_domain_violations
      assert_raises(ArgumentError){erfinv(-1)}
      assert_raises(ArgumentError){erfinv(1)}
      assert_nothing_thrown{erfinv(+1-Float::EPSILON)}
      assert_nothing_thrown{erfinv(-1+Float::EPSILON)}
    end
    def test_should_give_exactly_zero_at_midpoint
      assert_equal 0, erfinv(0)
    end
    def test_should_be_close_to_magic_answer_at_one_half # from A092676
      assert_in_delta erfinv(0.5),
                      0.4769362762044698733814183536431305598089697490594706447,
                      1e-10
    end
    def test_should_be_an_odd_function
      assert_equal erfinv(0.5), -erfinv(-0.5)
    end
    def test_should_produce_confidence_intervals_for_normal_distribution
      assert_in_delta 1.28155, erfinv(0.800)*sqrt(2), 1.0e-5
      assert_in_delta 1.64485, erfinv(0.900)*sqrt(2), 1.0e-5
      assert_in_delta 1.95996, erfinv(0.950)*sqrt(2), 1.0e-5
      assert_in_delta 2.32635, erfinv(0.980)*sqrt(2), 1.0e-5
      assert_in_delta 2.57583, erfinv(0.990)*sqrt(2), 1.0e-5
      assert_in_delta 2.80703, erfinv(0.995)*sqrt(2), 1.0e-5
      assert_in_delta 3.09023, erfinv(0.998)*sqrt(2), 1.0e-5
      assert_in_delta 3.29052, erfinv(0.999)*sqrt(2), 1.0e-5
    end
  end
end
