require 'test/unit'
require 'uq4sim/fuzzy_string'

class TestFuzzyStringRegexp < Test::Unit::TestCase

  include Uq4sim

  def test_integer_tolerance
    fs = FuzzyString.new '5+/-1'
    assert_equal( '5+/-1', fs.fuzzies.to_s )
  end

  def test_float_tolerance
    fs = FuzzyString.new '5.1+/-1.2'
    assert_equal( '5.1+/-1.2', fs.fuzzies.to_s )
  end

  def test_exponential_tolerance
    fs = FuzzyString.new '5.1e+01+/-1.2'
    assert_equal( '5.1e+01+/-1.2', fs.fuzzies.to_s )
  end

  def test_tolerance_with_format
    fs = FuzzyString.new '1.35+/-0.2_4.2f'
    assert_equal( '1.35+/-0.2_4.2f', fs.fuzzies.to_s )
    assert_equal( 4, fs.sample.to_s.length )
    assert_match( /\d\.\d\d/, fs.sample.to_s )
  end

  def test_tolerance_with_single_quoted_tag
    fs = FuzzyString.new "5+/-1 'tag'"
    assert_equal( "5+/-1 'tag'", fs.fuzzies.to_s )
  end

  def test_tolerance_with_double_quoted_tag_with_single_quote
    fs = FuzzyString.new '5+/-1 "mix\'d"'
    assert_equal( '5+/-1 "mix\'d"', fs.fuzzies.to_s )
  end

  def test_tolerance_with_more_general_tag
    fs = FuzzyString.new "5+/-1 'tag^2_2+3->4*1.0'"
    assert_equal( "5+/-1 'tag^2_2+3->4*1.0'", fs.fuzzies.to_s )
  end

  def test_tolerance_with_more_general_tag_followed_by_single_quote
    fs = FuzzyString.new "5+/-1 'tag' I'm here"
    assert_equal( "5+/-1 'tag'", fs.fuzzies.to_s )
  end

  def test_tolerance_with_leading_debris
    fs = FuzzyString.new "exp1 = 0.7+/-0.25U 'Eta_O2'"
    assert_equal( "0.7+/-0.25U 'Eta_O2'", fs.fuzzies.to_s )
  end

  def test_tolerance_with_trailing_debris
    fs = FuzzyString.new "0.7+/-0.25U 'Eta_O2' and things"
    assert_equal( "0.7+/-0.25U 'Eta_O2'", fs.fuzzies.to_s )
  end

  def test_percentage_tolerance
    fs = FuzzyString.new "5+/-1%"
    assert_equal( '5+/-1%', fs.fuzzies.to_s )
  end

  def test_zero_padded_percentage_tolerance
    fs = FuzzyString.new "5+/-03%"
    assert_equal( '5+/-03%', fs.fuzzies.to_s )
  end

  def test_order_tolerance
    fs = FuzzyString.new "5+/-1o"
    assert_equal( '5+/-1o', fs.fuzzies.to_s )
  end

  def test_tolerance_with_normal_distribution
    fs = FuzzyString.new "5+/-1N"
    assert_equal( '5+/-1N', fs.fuzzies.to_s )
  end

  def test_tolerance_with_uniform_distribution
    fs = FuzzyString.new "5+/-1U"
    assert_equal( '5+/-1U', fs.fuzzies.to_s )
  end

  def test_order_tolerance_with_normal_distribution
    fs = FuzzyString.new "5+/-1oN"
    assert_equal( '5+/-1oN', fs.fuzzies.to_s )
  end

end

class TestFuzzyStringCrisper < Test::Unit::TestCase

  include Uq4sim

  def test_strips_tolerance
    assert_equal( '5', FuzzyString.new('5+/-1oN').crisp )
    assert_equal( '5', FuzzyString.new('5+/-1o').crisp )
    assert_equal( '5', FuzzyString.new('5+/-1%').crisp )
    assert_equal( '5', FuzzyString.new('5+/-1U').crisp )
  end

end

class TestFuzzyStringSampler < Test::Unit::TestCase

  include Uq4sim
  
  def setup
    srand 1234 # set random number seed
  end

  def test_raw_normal_distribution
    fs = FuzzyString.new "5+/-1"
    assert_in_delta( 5.436, fs.sample.to_f, 0.0005 )
  end

  def test_raw_normal_distribution_explicit
    fs = FuzzyString.new "5+/-1", :randn
    assert_in_delta( 5.436, fs.sample.to_f, 0.0005 )
  end

  def test_with_tag
    fs = FuzzyString.new "5+/-1 'tag'"
    assert_in_delta( 5.436, fs.sample, 0.0005 )
  end

  def test_percent_normal_distribution
    fs = FuzzyString.new "5+/-50%"
    assert_in_delta( 6.090, fs.sample.to_f, 0.0005 )
  end

  def test_order_normal_distribution
    fs = FuzzyString.new "5+/-1o"
    assert_in_delta( 13.648, fs.sample.to_f, 0.0005 )
  end

  def test_raw_uniform_distribution
    fs = FuzzyString.new("5+/-1U")
    assert_in_delta( 4.692, fs.sample.to_f, 0.0005 )
    100.times do
      sample = fs.sample.to_f
      assert( (4..6).include?(sample),
              "#{sample} not within [4,6]" )
    end
  end

  def test_raw_uniform_distribution_explicit
    fs = FuzzyString.new("5+/-1", :randu)
    100.times do
      sample = fs.sample.to_f
      assert( (4..6).include?(sample),
              "#{sample} not within [4,6]" )
    end
  end

  def test_raw_uniform_distribution_with_decimal_tolerance
    fs = FuzzyString.new("0.7+/-0.25U 'tag'", :randu )
    100.times do |i|
      sample = fs.sample.to_f
      assert( (0.45..0.95).include?(sample),
              "#{sample} not within [0.45,0.95]" )
    end
  end

  def test_percent_uniform_distribution
    fs = FuzzyString.new("5+/-50%U")
    100.times do
      sample = fs.sample.to_f
      assert( (2.5..7.5).include?(sample),
              "#{sample} not within [2.5,7.5]" )
    end
  end

  def test_order_uniform_distribution
    fs = FuzzyString.new("5+/-1oU")
    100.times do
      sample = fs.sample.to_f
      assert( (0.5..50).include?(sample),
              "#{sample} not within [0.5,50.0]" )
    end
  end

  def test_order_distribution_around_zero
    fs = FuzzyString.new("0+/-1o")
    assert_equal( 0, fs.sample.to_f )
  end

  def test_negative_order_uniform_distribution
    fs = FuzzyString.new("-5+/-1oU")
    100.times do
      sample = fs.sample.to_f
      assert( (-50..-0.5).include?(sample),
              "#{sample} not within [-50,-0.5]" )
    end
  end

  def test_two_raw_normal_distributions
    fs = FuzzyString.new("5+/-1\n2+/-2").sample.split.map{|e| e.to_f}
    assert_in_delta( 5.436, fs.first, 0.0005 )
    assert_in_delta( 1.689, fs.last, 0.0005 )
  end

  def test_changing_distributions
    fs = FuzzyString.new("5+/-1\n2+/-2U\n5+/-1")
    assert_in_delta( 5.436, fs.sample.split.first.to_f, 0.0005 )
    100.times do
      sample = fs.sample.split.map{|e| e.to_f}[1]
      assert( (0..4).include?(sample), "#{sample} not in [0,4]" )
    end
  end

  def test_records_fields
    fs = FuzzyString.new("5+/-1 'onefish' and 2+/-1 'twofish'")
    fs.sample
    assert_equal( 2, fs.fields.size )
    assert( fs.fields.has_key?('onefish') )
    assert( fs.fields.has_key?('twofish') )
  end

  def test_records_unknown_fields
    fs = FuzzyString.new("5+/-1 and 2+/-1 and 3+/-0.5%U 'tagged'")
    4.times{fs.sample}
    assert_equal( 3, fs.fields.size )
    assert_equal( 2, fs.fields.select{ |k,v| k.match(/untagged/) }.size )
    assert( fs.fields.has_key?('untagged_1') )
    assert( fs.fields.has_key?('untagged_2') )
  end

end
