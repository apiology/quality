#!/usr/bin/env ruby

require 'rake'
require 'rake/tasklib'
require 'rbconfig'
require_relative '../quality_checker'

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
      # Defaults to %w{lib test spec feature}, which translates to *.rb in
      # the base directory, as well as lib, test, and feature.
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

        # likewise, but for File.open() on the count files
        @count_file = args[:count_file] || File

        # likewise, but for IO.read()/IO.exist? on the count files
        @count_io = args[:count_io] || IO

        # likewise, but for Dir.glob() on target Ruby files
        @globber = args[:globber] || Dir

        # likewise, but for checking whether a gem is installed
        @gem_spec = args[:gem_spec] || Gem::Specification

        # uses exist?() and open() to write out configuration files
        # for tools if needed (e.g., .cane file)
        @configuration_writer = args[:configuration_writer] || File

        # Class which actually runs the quality check commands
        @quality_checker_class =
          args[:quality_checker_class] || Quality::QualityChecker

        @skip_tools = []

        @output_dir = '.'

        yield self if block_given?

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
        installed = @gem_spec.find_all_by_name(tool).any?
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
        @globber.glob("#{@output_dir}/*_high_water_mark").each do |filename|
          run_ratchet_on_file(filename)
        end
      end

      def run_ratchet_on_file(filename)
        puts "Processing #{filename}"
        existing_violations = count_existing_violations(filename)
        new_violations = [0, existing_violations - 1].max
        write_violations(filename, new_violations)
        tighten_standard(filename) if new_violations != existing_violations
      end

      def write_violations(filename, new_violations)
        @count_file.open(filename, 'w') do |file|
          file.write(new_violations.to_s)
        end
      end

      def count_existing_violations(filename)
        existing_violations = @count_io.read(filename).to_i
        fail("Problem with file #{filename}") if existing_violations < 0
        existing_violations
      end

      def tighten_standard(filename)
        @cmd_runner
          .system("git commit -m 'tighten quality standard' #{filename}")
      end

      def ratchet_quality_cmd(cmd,
                              command_options,
                              &count_violations_on_line)
        quality_checker = @quality_checker_class.new(cmd,
                                                     command_options,
                                                     @output_dir)
        quality_checker.execute(&count_violations_on_line)
      end

      def quality_cane
        unless @configuration_writer.exist?('.cane')
          @configuration_writer.open('.cane', 'w') do |file|
            file.write('-f **/*.rb')
          end
        end
        ratchet_quality_cmd('cane',
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
        @ruby_dirs ||= %w{lib test spec feature}
      end

      def ruby_files
        @globber.glob('*.rb')
          .concat(@globber.glob(File.join("{#{ruby_dirs.join(',')}}",
                                          '**', '*.rb'))).join(' ')
      end

      def quality_reek
        args = "--single-line #{ruby_files}"
        ratchet_quality_cmd('reek',
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
        ratchet_quality_cmd('flog',
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
        ratchet_quality_cmd('flay',
                            args: "-m 75 -t 99999 #{ruby_files}",
                            emacs_format: true) do |line|
          if line =~ /^[0-9]*\).* \(mass = ([0-9]*)\)$/
            $1.to_i
          else
            0
          end
        end
      end

      def quality_rubocop
        ratchet_quality_cmd('rubocop',
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
  end
end
