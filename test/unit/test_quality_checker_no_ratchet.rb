# frozen_string_literal: true

require_relative 'test_quality_checker'

# Unit test the QualityChecker class
class TestQualityCheckerNoRatchet < TestQualityChecker
  def quality_checker_dont_ratchet
    command_options = {}
    num_violations = 400
    existing_violations = 500
    minimum_threshold = 500
    get_test_object('foo', command_options, 'my_output_dir', false,
                    minimum_threshold) do
      setup_execute_mocks(command_options, num_violations,
                          existing_violations, minimum_threshold)
    end
  end

  def test_execute_dont_ratchet
    quality_checker_dont_ratchet.execute { |line| assert_equal(line, 'line') }
  end
end
