# frozen_string_literal: true

require_relative '../test_helper'

# Test the JSCS module
class TestJscs < MiniTest::Test
  def test_jscs_unconfigured
    lines = ['No configuration found']
    m = MockRunner.new(lines)
    assert_equal(0, m.run('jscs'))
  end
end
