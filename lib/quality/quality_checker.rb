# frozen_string_literal: true

require_relative 'command_output_processor'
require_relative 'process'
require_relative 'ruby_spawn'
require 'high_water_mark/threshold'

module Quality
  # Runs a quality-checking, command, checks it agaist the existing
  # number of violations for that command, and decreases that number
  # if possible, or outputs data if the number of violations increased.
  class QualityChecker
    def initialize(cmd, command_options, output_dir, verbose,
                   minimum_threshold,
                   logger: STDOUT,
                   count_file: File,
                   count_io: IO,
                   command_output_processor_class:
                     Quality::CommandOutputProcessor,
                   count_dir: Dir,
                   process_class: Process)
      @minimum_threshold = minimum_threshold
      @count_file = count_file
      @count_io = count_io
      @command_output_processor_class = command_output_processor_class
      @logger = logger
      @count_dir = count_dir
      @cmd = cmd
      @command_options = command_options
      @verbose = verbose
      @count_dir.mkdir(output_dir) unless @count_file.exists?(output_dir)
      @threshold = HighWaterMark::Threshold.new(cmd,
                                                count_io: count_io,
                                                count_file: count_file,
                                                output_dir: output_dir)
      @process_class = process_class
    end

    def execute(&count_violations_on_line)
      processor, exit_status = process_command(&count_violations_on_line)
      @violations = processor.violations
      check_exit_status(exit_status)
      ratchet_violations
    end

    private

    def process_command(&count_violations_on_line)
      processor = @command_output_processor_class.new
      processor.emacs_format = @command_options[:emacs_format]
      exit_status = run_command(processor, &count_violations_on_line)
      [processor, exit_status]
    end

    def run_command(processor, &count_violations_on_line)
      runner = @process_class.new(full_cmd + ' 2>&1')

      puts rendered_full_cmd if @verbose
      runner.run do |file|
        processor.file = file
        @command_output = processor.process(&count_violations_on_line)
      end
    end

    def check_exit_status(exit_status)
      return if @command_options[:gives_error_code_on_violations] ||
                @command_options[:gives_error_code_on_no_relevant_code]
      return unless exit_status.nonzero?

      raise("Error detected running #{rendered_full_cmd}.  " \
            "Exit status is #{exit_status}.  Output was #{@command_output}")
    end

    MAX_VIOLATIONS = 9_999_999_999

    def existing_violations
      @existing_violations ||= (@threshold.threshold || MAX_VIOLATIONS)
    end

    def rendered_full_cmd
      full_cmd.scan(/.{1,78}/).join("\\\n")
    end

    def error_too_many_violations!
      raise("Output from:\n\n" \
            "#{rendered_full_cmd}\n\n#{@command_output}\n\n" \
            "Reduce total number of #{@cmd} violations " \
            "to #{existing_violations} or below!")
    end

    def violations_to_write
      @violations_to_write ||= [@violations, @minimum_threshold].max
    end

    def report_ratchet
      if @violations < existing_violations &&
         existing_violations != MAX_VIOLATIONS
        @logger.puts 'Ratcheting quality up...'
      end
    end

    def ratchet_violations
      report_violations(existing_violations)
      if @violations > [existing_violations, @minimum_threshold].max
        error_too_many_violations!
      elsif violations_to_write != existing_violations
        report_ratchet
        write_violations(violations_to_write)
      end
    end

    def report_violations(existing)
      if existing != MAX_VIOLATIONS
        @logger.puts "Existing violations: #{existing}"
      end
      @logger.puts "Found #{@violations} #{@cmd} violations"
    end

    def full_cmd
      args = @command_options[:args] || ''
      @found_output = false
      RubySpawn.new(@cmd, args).invocation
    end

    def write_violations(new_violations)
      @threshold.write_violations(new_violations)
    end
  end
end
