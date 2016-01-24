require 'test/unit'
require 'uq4sim/enumerable_sum'

class TestEnumerableSum < Test::Unit::TestCase

  def test_simple_sum
    assert_equal( 15, (0..5).sum )
  end

end
