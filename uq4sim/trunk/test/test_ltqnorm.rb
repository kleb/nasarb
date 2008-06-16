require 'uq4sim/ltqnorm'

class TestLtqnorm < Test::Unit::TestCase
  include Math
  def test_should_reject_domain_violations
    assert_raises(ArgumentError){ltqnorm(0)}
    assert_raises(ArgumentError){ltqnorm(1)}
    assert_nothing_thrown{ltqnorm(0+Float::EPSILON)}
    assert_nothing_thrown{ltqnorm(1-Float::EPSILON)}
  end
  def test_should_give_exactly_zero_at_midpoint
    assert_equal 0, ltqnorm(0.5)
  end
  def test_should_be_close_to_magic_answer_at_one_half # from A092676
    assert_in_delta ltqnorm(0.75)/sqrt(2),
                    0.4769362762044698733814183536431305598089697490594706447,
                    1e-10
  end
  def test_should_be_an_odd_function
    assert_equal ltqnorm(0.25), -ltqnorm(0.75)
  end
end
