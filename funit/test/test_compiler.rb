require 'test/unit'
require 'funit/compiler'

class TestCompiler < Test::Unit::TestCase

  def test_no_environment_compiler_name
    begin
      orig_FC = ENV['FC']
      ENV.delete 'FC'
      assert_raises(RuntimeError) {Funit::Compiler.new}
    ensure
      ENV['FC'] = orig_FC
    end
  end  

end
