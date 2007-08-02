require 'test/unit'
require 'uq4sim/correlation'

class TestCorrelation < Test::Unit::TestCase
  
  include Uq4sim

  def test_1x1_perfectly_correlated
    x = [ [0,1] ]
    y = [ [0,1] ]
    c, c2 = correlation(x,y)
    assert_equal( [ [ 1.0 ] ], c )
    assert_equal( [ [ 1.0 ] ], c2 )
  end

  def test_1x1_perfectly_anti_correlated
    x = [ [0,1] ]
    y = [ [1,0] ]
    c, c2 = correlation(x,y)
    assert_equal( [ [ -1.0 ] ], c )
    assert_equal( [ [  1.0 ] ], c2 )
  end

  def test_1x1_perfectly_uncorrelated
    x = [ [0,1] ]
    y = [ [0,0] ]
    c, c2 = correlation(x,y)
    assert_equal( [ [ 0.0 ] ], c )
    assert_equal( [ [ 0.0 ] ], c2 )
  end

  def test_2x1_perfectly_correlated
    x = [ [0,1], [0,1] ]
    y = [ [0,1] ]
    c, c2 = correlation(x,y)
    assert_equal( [ [ 1.0 ], [ 1.0 ] ], c )
    assert_equal( [ [ 0.5 ], [ 0.5 ] ], c2 )
  end

  def test_2x1_perfectly_correlated_and_uncorrelated
    x = [ [0,1], [0,0] ]
    y = [ [0,1] ]
    c, c2 = correlation(x,y)
    assert_equal( [ [ 1.0 ], [ 0.0 ] ], c )
    assert_equal( [ [ 1.0 ], [ 0.0 ] ], c2 )
  end

  def test_1x2_perfectly_anti_correlated
    x = [ [0,1] ]
    y = [ [1,0], [1,0] ]
    c, c2 = correlation(x,y)
    assert_equal( [ [ -1.0, -1.0 ] ], c )
    assert_equal( [ [  1.0,  1.0 ] ], c2 )
  end

  def test_1x2_perfectly_correlated_and_uncorrelated
    x = [ [0,1] ]
    y = [ [0,1], [0,0] ]
    c, c2 = correlation(x,y)
    assert_equal( [ [ 1.0, 0.0 ] ], c )
    assert_equal( [ [ 1.0, 0.0 ] ], c2 )
  end

end
