#!/usr/bin/env ruby

require 'rake'
require 'rake/tasklib'
require 'rbconfig'
require_relative '../quality_checker'
require_relative '../tools/cane'
require_relative '../tools/flay'
require_relative '../tools/flog'
require_relative '../tools/reek'
require_relative '../tools/rubocop'

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
      include Tools::Cane
      include Tools::Flay
      include Tools::Flog
      include Tools::Reek
      include Tools::Rubocop

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
      # Defaults to %w(app lib test spec feature), which translates to *.rb in
      # the base directory, as well as those directories.
      attr_writer :ruby_dirs

      # Relative path to output directory where *_high_water_mark
      # files will be read/written
      #
      # Defaults to .
      attr_writer :output_dir

      # Defines a new task, using the name +name+.
      def initialize(args = {})
        parse_args(args)

        @skip_tools = []

        @output_dir = '.'

        yield self if block_given?

        define
      end

      def parse_task_name_args(args)
        @quality_name = args[:quality_name] || 'quality'

        @ratchet_name = args[:ratchet_name] || 'ratchet'
      end

      def parse_args(args)
        parse_task_name_args(args)
        parse_unit_test_overrides(args)
      end

      def parse_unit_test_overrides(args)
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
      end

      private

      def define # :nodoc:
        desc 'Verify quality has increased or stayed ' \
          'the same' unless ::Rake.application.last_comment
        @dsl.define_task(quality_name) { run_quality }
        @dsl.define_task(ratchet_name) { run_ratchet }
        tools.each do |tool|
          @dsl.define_task(tool) { run_quality_with_tool(tool) }
        end
      end

      def tools
        self.class.ancestors.map do |ancestor|
          ancestor_name = ancestor.to_s
          next unless ancestor_name.start_with?('Quality::Tools::')
          ancestor_name.split('::').last.downcase
        end.compact
      end

      def run_quality
        tools.each do |tool|
          run_quality_with_tool(tool)
        end
      end

      def run_quality_with_tool(tool)
        installed = @gem_spec.find_all_by_name(tool).any?
        suppressed = @skip_tools.include? tool

        if installed && !suppressed
          method("quality_#{tool}".to_sym).call
        elsif !installed
          puts "#{tool} not installed"
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
      end

      def write_violations(filename, new_violations)
        @count_file.open(filename, 'w') do |file|
          file.write(new_violations.to_s + "\n")
        end
      end

      def count_existing_violations(filename)
        existing_violations = @count_io.read(filename).to_i
        fail("Problem with file #{filename}") if existing_violations < 0
        existing_violations
      end

      def ratchet_quality_cmd(cmd,
                              command_options,
                              &count_violations_on_line)
        quality_checker = @quality_checker_class.new(cmd,
                                                     command_options,
                                                     @output_dir)
        quality_checker.execute(&count_violations_on_line)
      end

      def ruby_dirs
        @ruby_dirs ||= %w(app lib test spec feature)
      end

      def ruby_files_glob
        File.join("{#{ruby_dirs.join(',')}}",
                  '**', '*.rb')
      end

      def ruby_files
        @globber.glob('*.rb')
          .concat(@globber.glob(ruby_files_glob)).join(' ')
      end
    end
  end
end
