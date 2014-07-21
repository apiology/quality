require_relative 'test_helper'

# Unit test the QualityChecker class
class TestQualityChecker < MiniTest::Unit::TestCase
  def quality_checker_ratchet
    command_options = {}
    num_violations = 523
    existing_violations = 524
    get_test_object('foo',
                    command_options,
                    '.') do
      setup_execute_mocks(command_options,
                          num_violations,
                          existing_violations)
    end
  end

  def test_execute
    quality_checker_ratchet.execute do |line|
      assert_equal(line, 'line')
    end
  end

  def quality_checker_no_existing_violations
    command_options = {}
    num_violations = 523
    existing_violations = nil

    get_test_object('foo',
                    command_options,
                    '.') do
      setup_execute_mocks(command_options,
                          num_violations,
                          existing_violations)
    end
  end

  def test_execute_no_existing_violations
    quality_checker_no_existing_violations.execute do |line|
      assert_equal(line, 'line')
    end
  end

  def setup_execute_mocks(command_options,
                          num_violations,
                          existing_violations)
    command_output_processor = expect_create_new_processor
    command_output_processor.expects(:emacs_format=)
      .with(command_options[:emacs_format])
    expect_run_command(command_output_processor)
    command_output_processor.expects(:violations).returns(num_violations)
    expect_twiddle_high_water_mark_files(num_violations, existing_violations)
  end

  def expect_twiddle_high_water_mark_files(num_violations, existing_violations)
    hwm_filename = './foo_high_water_mark'
    expect_existing_violations_read(existing_violations, hwm_filename)
    expect_write_new_violations(num_violations, hwm_filename)
  end

  def process_runner
    @process_runner ||= mock('process_runner')
  end

  def expect_run_command(command_output_processor)
    command_output = mock('command_output')
    @mocks[:process_runner_class]
      .expects(:new).with('foo', popener: @mocks[:popener])
      .returns(process_runner)
    process_runner.expects(:run).yields(command_output).returns(0)
    command_output_processor.expects(:file=).with(command_output)
    process_expectation = command_output_processor.expects(:process)
    %w(line line).each do |line|
      process_expectation.yields(line)
    end
  end

  def expect_create_new_processor
    command_output_processor = mock('command_output_processor')
    @mocks[:command_output_processor_class]
      .expects(:new).returns(command_output_processor)
    command_output_processor
  end

  def expect_write_new_violations(num_violations, hwm_filename)
    file = mock('file')
    @mocks[:count_file].expects(:open).with(hwm_filename, 'w').yields(file)
    file.expects(:write).with(num_violations.to_s + "\n")
  end

  def expect_existing_violations_read(existing_violations, hwm_filename)
    if existing_violations.nil?
      expect_file_exist?(hwm_filename, false)
    else
      expect_file_exist?(hwm_filename, true)
      @mocks[:count_io].expects(:read).with(hwm_filename)
        .returns(existing_violations.to_s)
    end
  end

  def expect_file_exist?(filename, exists)
    @mocks[:count_file].expects(:exist?).with(filename).returns(exists)
  end

  def test_mocks
    {
      popener: mock('popener'),
      count_file: mock('count_file'),
      count_io: mock('count_io'),
      command_output_processor_class: mock('command_output_processor_class'),
      process_runner_class: mock('process_runner_class'),
    }
  end

  def get_test_object(cmd, command_options, output_dir, &twiddle_mocks)
    @mocks = test_mocks
    yield unless twiddle_mocks.nil?
    Quality::QualityChecker.new(cmd, command_options, output_dir, @mocks)
  end
end
