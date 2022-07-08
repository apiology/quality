#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../test_helper'
require_relative 'mock_runner'

require 'quality/tools/pycodestyle'

# Unit test the Pycodestyle class
class TestPycodestyle < MiniTest::Test
  def test_pycodestyle
    lines = [
      'Usage: something something something',
      'pycodestyle: something something something',
      'real line',
    ]
    m = MockRunner.new(lines)
    assert_equal(1, m.run('pycodestyle'))
  end
end
