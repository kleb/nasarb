require 'test/unit'
require 'uq4sim'

class Array # mixin statistics
  include Uq4sim::Statistics
end

class TestUq4sim < Test::Unit::TestCase

  # FIXME
  def test_runner
    assert(true)
  end

end