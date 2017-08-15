# frozen_string_literal: true

require_relative 'test_quality_checker'

# Unit test the QualityChecker class
class TestQualityCheckerRatchet < TestQualityChecker
  def quality_checker_ratchet
    command_options = {}
    num_violations = 523
    existing_violations = 524
    minimum_threshold = 500
    get_test_object('foo', command_options, 'my_output_dir', false,
                    minimum_threshold) do
      setup_execute_mocks(command_options, num_violations,
                          existing_violations, minimum_threshold)
    end
  end

  def test_execute_ratchet
    quality_checker_ratchet.execute { |line| assert_equal(line, 'line') }
  end

  def quality_checker_slip_up_if_still_below_threshold
    command_options = {}
    num_violations = 517
    existing_violations = 485
    minimum_threshold = 550
    get_test_object('foo', command_options, 'my_output_dir', false,
                    minimum_threshold) do
      setup_execute_mocks(command_options, num_violations,
                          existing_violations, minimum_threshold)
    end
  end

  def test_execute_slip_up_if_still_below_threshold
    quality_checker_slip_up_if_still_below_threshold.execute do |line|
      assert_equal(line, 'line')
    end
  end

  def quality_checker_no_existing_violations
    command_options = {}
    num_violations = 523
    existing_violations = nil
    minimum_threshold = 500

    get_test_object('foo', command_options, 'my_output_dir', false,
                    minimum_threshold) do
      setup_execute_mocks(command_options, num_violations,
                          existing_violations, minimum_threshold)
    end
  end

  def test_execute_no_existing_violations
    quality_checker_no_existing_violations.execute do |line|
      assert_equal(line, 'line')
    end
  end
end
