# frozen_string_literal: true

require_relative 'test_helper'

# Unit test the Version class
class TestVersion < MiniTest::Test
  def test_version_specified
    refute_nil(Quality::VERSION)
  end
end
