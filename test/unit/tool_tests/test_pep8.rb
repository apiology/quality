#!/usr/bin/env ruby

require_relative '../test_helper.rb'
require_relative 'mock_class'


require 'quality/tools/pep8'
# XXX: Upgrade Rubocop

# Unit test the Task class
class TestPep8 < MiniTest::Test
  def test_pep8
    lines = [
      'Usage: something something something',
      'pep8: something something something',
      'real line',
    ]
    m = MockClass.new(lines)
    assert_equal(1, m.run('pep8'))
  end
end
