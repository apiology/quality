require_relative 'command_output_processor'
require_relative 'process_runner'

module Quality
  # Runs a quality-checking, command, checks it agaist the existing
  # number of violations for that command, and decreases that number
  # if possible, or outputs data if the number of violations increased.
  class QualityChecker
    def initialize(cmd, command_options, output_dir, dependencies = {})
      @count_file = dependencies[:count_file] || File
      @count_io = dependencies[:count_io] || IO
      @command_output_processor_class =
        dependencies[:command_output_processor_class] ||
        Quality::CommandOutputProcessor
      @cmd = cmd
      @command_options = command_options
      @filename = File.join(output_dir, "#{cmd}_high_water_mark")
      @process_runner_class =
        dependencies[:process_runner_class] || ProcessRunner
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
      runner = @process_runner_class.new(full_cmd)

      runner.run do |file|
        processor.file = file
        @command_output = processor.process(&count_violations_on_line)
      end
    end

    def check_exit_status(exit_status)
      return if @command_options[:gives_error_code_on_violations]

      fail("Error detected running #{full_cmd}.  " \
           "Exit status is #{exit_status}, " \
           "output is [#{out}]") if exit_status != 0
    end

    def existing_violations
      if @count_file.exist?(@filename)
        @count_io.read(@filename).to_i
      else
        9_999_999_999
      end
    end

    def ratchet_violations
      existing = existing_violations
      report_violations(existing)
      if @violations > existing
        fail("Output from #{@cmd}\n\n#{@command_output}\n\n" \
             "Reduce total number of #{@cmd} violations " \
             "to #{existing} or below!")
      elsif @violations < existing
        puts 'Ratcheting quality up...'
        write_violations(@violations)
      end
    end

    def report_violations(existing)
      puts "Existing violations: #{existing}"
      puts "Found #{@violations} #{@cmd} violations"
    end

    private

    def full_cmd
      args = @command_options[:args]
      args ||= ''

      @found_output = false
      if args.size > 0
        "#{cmd_with_ruby_hack_prefix} #{args}"
      else
        "#{cmd_with_ruby_hack_prefix}"
      end
    end

    def cmd_with_ruby_hack_prefix
      if defined?(RUBY_ENGINE) && (RUBY_ENGINE == 'jruby')
        "jruby -S #{@cmd}"
      elsif RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
        "#{@cmd}.bat"
      else
        @cmd
      end
    end

    def write_violations(new_violations)
      @count_file.open(@filename, 'w') do |file|
        file.write(new_violations.to_s + "\n")
      end
    end
  end
end
