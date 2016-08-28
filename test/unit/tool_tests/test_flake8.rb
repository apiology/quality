#!/usr/bin/env ruby

require_relative '../test_helper.rb'
require_relative 'mock_runner'

require 'quality/tools/flake8'

# Unit test the Task class
class TestFlake8 < MiniTest::Test
  def test_flake8
    lines = [
      'Usage: something something something',
      'flake8: something something something',
      'real line',
    ]
    m = MockRunner.new(lines)
    assert_equal(1, m.run('flake8'))
  end
end
