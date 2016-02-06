require_relative '../test_helper'

class TestJscs < MiniTest::Test
  def test_jscs_unconfigured
    lines = ['No configuration found']
    m = MockClass.new(lines)
    assert_equal(0, m.run('jscs'))
  end
end
