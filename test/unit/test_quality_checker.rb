# frozen_string_literal: true

# !/usr/bin/env ruby

require_relative 'test_helper'

# Unit test the QualityChecker class
class TestQualityChecker < MiniTest::Test
  def setup_execute_mocks(command_options, num_violations, existing_violations,
                          minimum_threshold)
    command_output_processor = expect_create_new_processor
    command_output_processor.expects(:emacs_format=)
                            .with(command_options[:emacs_format])
    expect_run_command(command_output_processor)
    expect_new_violations_determined(num_violations)
    expect_twiddle_high_water_mark_files(num_violations, existing_violations,
                                         minimum_threshold)
  end

  def expect_new_violations_determined(num_violations)
    command_output_processor.expects(:violations).returns(num_violations)
    @mocks[:logger].expects(:puts)
                   .with("Found #{num_violations} foo violations")
  end

  def expect_twiddle_high_water_mark_files(num_violations, existing_violations,
                                           minimum_threshold)
    hwm_filename = 'my_output_dir/foo_high_water_mark'
    expect_existing_violations_read(existing_violations, hwm_filename)
    return if [minimum_threshold, num_violations].max == existing_violations

    if !existing_violations.nil? && num_violations < existing_violations
      @mocks[:logger].expects(:puts).with('Ratcheting quality up...')
    end
    expect_write_new_violations([minimum_threshold, num_violations].max,
                                hwm_filename)
  end

  def expect_metrics_dir_already_there
    @mocks[:count_file].expects(:exists?).with('my_output_dir').returns(true)
  end

  let_mock :process, :command_output, :file, :command_output_processor

  def expect_process_created(command)
    @mocks[:process_class].expects(:new).with(command + ' 2>&1')
                          .returns(process)
  end

  def expect_process_class_initialized
    if defined?(RUBY_ENGINE) && (RUBY_ENGINE == 'jruby')
      expect_process_created('jruby -S foo')
    else
      expect_process_created('foo')
    end
  end

  def expect_run_command(command_output_processor)
    expect_process_class_initialized
    process.expects(:run).yields(command_output).returns(0)
    command_output_processor.expects(:file=).with(command_output)
    process_expectation = command_output_processor.expects(:process)
    %w[line line].each { |line| process_expectation.yields(line) }
  end

  def expect_create_new_processor
    expect_metrics_dir_already_there
    @mocks[:command_output_processor_class]
      .expects(:new).returns(command_output_processor)
    command_output_processor
  end

  def expect_write_new_violations(num_violations, hwm_filename)
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
      @mocks[:logger].expects(:puts)
                     .with("Existing violations: #{existing_violations}")
    end
  end

  def expect_file_exist?(filename, exists)
    @mocks[:count_file].expects(:exist?).with(filename).returns(exists)
  end

  def test_mocks
    { count_file: mock('count_file'), count_io: mock('count_io'),
      command_output_processor_class: mock('command_output_processor_class'),
      process_class: mock('process_class'), count_dir: mock('dir'),
      logger: mock('logger') }
  end

  def get_test_object(cmd, options, output_dir, verbose, minimum_threshold,
                      &twiddle_mocks)
    @mocks = test_mocks
    yield unless twiddle_mocks.nil?
    Quality::QualityChecker.new(cmd, options, output_dir, verbose,
                                minimum_threshold, **@mocks)
  end
end
