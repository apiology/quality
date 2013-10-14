#!/usr/bin/env ruby

require 'rake'
require 'rake/tasklib'
require 'rbconfig'

module Quality

  #
  # Defines a task library for running quality's various tools
  #
  module Rake

    # A Rake task that run quality tools on a set of source files, and
    # enforce a ratcheting quality level.
    #
    # Example:
    #
    #   require 'quality/rake/task'
    #
    #   Quality::Rake::Task.new do |t|
    #   end
    #
    # This will create a task that can be run with:
    #
    #   rake quality
    #
    class Task < ::Rake::TaskLib

      # Name of quality task.
      # Defaults to :quality.
      attr_accessor :quality_name

      # Name of ratchet task.
      # Defaults to :ratchet.
      attr_accessor :ratchet_name

      # Array of strings describing tools to be skipped--e.g., ["cane"]
      #
      # Defaults to []
      attr_accessor :skip_tools

      # Array of directory names which contain ruby files to analyze.
      #
      # Defaults to %w{lib test features}, which translates to *.rb in
      # the base directory, as well as lib, test, and features.
      attr_writer :ruby_dirs

      # Relative path to output directory where *_high_water_mark
      # files will be read/written
      #
      # Defaults to .
      attr_writer :output_dir

      # Defines a new task, using the name +name+.
      def initialize(args = {})
        @quality_name = args[:quality_name] || 'quality'

        @ratchet_name = args[:ratchet_name] || 'ratchet'

        # allow unit tests to override the class that Rake DSL
        # messages are sent to.
        @dsl = args[:dsl] || ::Rake::Task

        # likewise, but for system()
        @cmd_runner = args[:cmd_runner] || Kernel

        # likewise, but for IO.popen()
        @popener = args[:popener] || IO

        # likewise, but for File.open() on the count files
        @count_file = args[:count_file] || File

        # likewise, but for IO.read()/IO.exist? on the count files
        @count_io = args[:count_io] || IO

        # likewise, but for Dir.glob() on target Ruby files
        @globber = args[:globber] || Dir

        # uses exist?() and open() to write out configuration files
        # for tools if needed (e.g., .cane file)
        @configuration_writer = args[:configuration_writer] || File

        @skip_tools = [] if @skip_tools.nil?
        @config_files = nil
        @source_files = nil
        @ruby_opts = []
        @fail_on_error = true
        @sort = nil

        yield self if block_given?
        @config_files ||= 'config/**/*.reek'
        @source_files ||= 'lib/**/*.rb'
        @output_dir   ||= "."
        define
      end

  private

      def define # :nodoc:
        desc 'Verify quality has increased or stayed ' +
          'the same' unless ::Rake.application.last_comment
        @dsl.define_task(quality_name) { run_quality }
        @dsl.define_task(ratchet_name) { run_ratchet }
      end

      def run_quality
        tools = ['cane', 'flog', 'flay', 'reek', 'rubocop']
        tools.each do |tool|
          run_quality_with_tool(tool)
        end
      end

      def run_quality_with_tool(tool)
        installed = Gem::Specification.find_all_by_name(tool).any?
        suppressed = @skip_tools.include? tool

        if !installed
          puts "#{tool} not installed"
        elsif suppressed
          puts "Suppressing use of #{tool}"
        else
          method("quality_#{tool}".to_sym).call
        end
      end

      def run_ratchet
        @globber.glob("*_high_water_mark").each do |filename|
          run_ratchet_on_file(filename)
        end
      end

      def run_ratchet_on_file(filename)
        puts "Processing #{filename}"
        existing_violations = count_existing_violations(filename)
        new_violations = [0, existing_violations - 1].max
        write_violations(filename, new_violations)
        if new_violations != existing_violations
          tighten_standard(filename)
        end
      end

      def write_violations(filename, new_violations)
        @count_file.open(filename, 'w') do |file|
          file.write(new_violations.to_s)
        end
      end      

      def count_existing_violations(filename)
        existing_violations = @count_io.read(filename).to_i
        if existing_violations < 0
          raise "Problem with file #{filename}"
        end
        existing_violations
      end

      def tighten_standard(filename)
        @cmd_runner
          .system("git commit -m 'tighten quality standard' #{filename}")
      end

      def ratchet_quality_cmd(cmd,
                              command_options,
                              &count_violations_on_line)
        quality_checker = QualityChecker.new(cmd,
                                             command_options,
                                             @output_dir,
                                             :popener => @popener,
                                             :count_file => @count_file,
                                             :count_io => @count_io)
        quality_checker.execute(&count_violations_on_line)
      end

      def quality_cane
        if ! @configuration_writer.exist?(".cane")
          @configuration_writer.open(".cane", "w") do |file|
            file.write("-f **/*.rb")
          end
        end
        ratchet_quality_cmd("cane",
                            gives_error_code_on_violations: true,
                            emacs_format: true) do |line|
          if line =~ /\(([0-9]*)\):$/
            $1.to_i
          else
            0
          end
        end
      end

      def ruby_dirs
        @ruby_dirs ||= %w{lib test features}
      end

      def ruby_files
        @globber.glob('*.rb')
          .concat(@globber.glob(File.join("{#{ruby_dirs.join(',')}}",
                                          '**', '*.rb'))).join(' ')
      end

      def quality_reek
        args = "--single-line #{ruby_files}"
        ratchet_quality_cmd("reek",
                            args: args,
                            emacs_format: true,
                            gives_error_code_on_violations: true) do |line|
          self.class.count_reek_violations(line)
        end
      end

      def self.count_reek_violations(line)
        if line =~ /^  .* (.*)$/
          1
        else
          0
        end
      end

      def quality_flog
        ratchet_quality_cmd("flog",
                            args: "--all --continue --methods-only #{ruby_files}",
                            emacs_format: true) do |line|
          self.class.count_violations_in_flog_output(line)
        end
      end

      def self.count_violations_in_flog_output(line, threshold = 50)
        if line =~ /^ *([0-9.]*): flog total$/
          0
        elsif line =~ /^ *([0-9.]*): (.*) .*.rb:[0-9]*$/
          score = $1.to_i
          if score > threshold
            1
          else
            0
          end
        else
          0
        end
      end

      def quality_flay
        ratchet_quality_cmd("flay",
                            args: "-m 75 -t 99999 #{ruby_files}",
                            emacs_format: true) { |line|
          if line =~ /^[0-9]*\).* \(mass = ([0-9]*)\)$/
            $1.to_i
          else
            0
          end
        }
      end

      def quality_rubocop
        ratchet_quality_cmd("rubocop",
                            gives_error_code_on_violations: true,
                            args: "--format emacs #{ruby_files}") do |line|
          self.class.count_rubocop_violations(line)
        end
      end

      def self.count_rubocop_violations(line)
        if line =~ /^.* file[s|] inspected, (.*) offence[s|] detected$/
          0
        else
          1
        end
      end
    end

    # Class processes output from a code quality command, tweaking it
    # for editor output and counting the number of violations found
    class CommandOutputProcessor
      attr_accessor :emacs_format
      attr_accessor :file
      attr_reader :found_output
      attr_reader :violations

      def initialize
        @emacs_format = false
        @found_output = false
        @violations = 0
      end

      def process!(&count_violations_on_line)
        process_file(file, &count_violations_on_line)
      end

      def process_file(file, &count_violations_on_line)
        out = ""
        while @current_line = file.gets
          out <<
            process_line(&count_violations_on_line)
        end
        out
      end

      def process_line( &count_violations_on_line)
        output =
          if emacs_format
            preprocess_line_for_emacs
          else
            @current_line
          end
        found_output = true
        @violations += yield @current_line
        output
      end

      def preprocess_line_for_emacs
        if @current_line =~ /^ *(\S*.rb:[0-9]*) *(.*)/
          $1 + ": " + $2 + "\n"
        elsif @current_line =~ /^ *(.*) +(\S*.rb:[0-9]*) *(.*)/
          $2 + ": " + $1 + "\n"
        else
          @current_line
        end
      end
    end

    # Runs a quality-checking, command, checks it agaist the existing
    # number of violations for that command, and decreases that number
    # if possible, or outputs data if the number of violations increased.
    class QualityChecker
      def initialize(cmd, command_options, output_dir, dependencies = {})
        @popener = dependencies[:popener] || IO
        @count_file = dependencies[:count_file] || File
        @count_io = dependencies[:count_io] || IO
        @cmd = cmd
        @command_options = command_options
        @filename = File.join(output_dir, "#{cmd}_high_water_mark")
      end

      def execute(&count_violations_on_line)
        processor, exit_status = process_command(&count_violations_on_line)
        @violations = processor.violations
        check_exit_status(exit_status)
        ratchet_violations
      end

      def process_command(&count_violations_on_line)
        processor = CommandOutputProcessor.new
        processor.emacs_format = @command_options[:emacs_format]
        exit_status = run_command(processor, &count_violations_on_line)
        [processor, $?.exitstatus]
      end

      def run_command(processor, &count_violations_on_line)
        @popener.popen(full_cmd) do |file|
          processor.file = file
          @command_output = processor.process!(&count_violations_on_line)
        end
      end

      def check_exit_status(exit_status)
        if !@command_options[:gives_error_code_on_violations]
          if exit_status != 0
            fail("Error detected running #{full_cmd}.  " +
                 "Exit status is #{exit_status}, output is [#{out}]")
          end
        end
      end

      def existing_violations
        if @count_file.exist?(@filename)
          @count_io.read(@filename).to_i
        else
          9999999999
        end
      end

      def ratchet_violations
        existing = existing_violations
        report_violations(existing)
        if @violations > existing
          fail("Output from #{@cmd}\n\n#{@command_output}\n\n" +
               "Reduce total number of #{@cmd} violations " +
               "to #{existing} or below!")
        elsif @violations < existing
          puts "Ratcheting quality up..."
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

        found_output = false
        if args.size > 0
          full_cmd = "#{get_cmd_with_ruby_hack_prefix} #{args}"
        else
          full_cmd = "#{get_cmd_with_ruby_hack_prefix}"
        end
      end

      def get_cmd_with_ruby_hack_prefix
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
          file.write(new_violations.to_s)
        end
      end
    end
  end
end
