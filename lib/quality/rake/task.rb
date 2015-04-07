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
require_relative '../tools/bigfiles'

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
      include Tools::BigFiles

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

      # Log command executation
      #
      # Defaults to false
      attr_accessor :verbose

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
      def initialize(dsl: ::Rake::Task,
                     cmd_runner: Kernel,
                     count_file: File,
                     count_io: IO,
                     globber: Dir,
                     gem_spec: Gem::Specification,
                     configuration_writer: File,
                     quality_checker_class:
                       Quality::QualityChecker,
                     quality_name: 'quality',
                     ratchet_name: 'ratchet')
        @dsl, @cmd_runner, @count_file = dsl, cmd_runner, count_file
        @count_io, @globber, @gem_spec = count_io, globber, gem_spec
        @configuration_writer = configuration_writer
        @quality_checker_class = quality_checker_class
        @quality_name, @ratchet_name = quality_name, ratchet_name

        @skip_tools = []

        @verbose = false

        @output_dir = 'metrics'

        yield self if block_given?

        define
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
                                                     @output_dir,
                                                     verbose)
        quality_checker.execute(&count_violations_on_line)
      end

      def ruby_dirs
        @ruby_dirs ||= %w(app lib test spec feature)
      end

      def source_files_glob(extensions = 'rb,swift,cpp,c,java,py')
        File.join("{#{ruby_dirs.join(',')}}",
                  '**', "*.{#{extensions}}")
      end

      def ruby_files_glob
        source_files_glob('rb')
      end

      def ruby_files
        @globber.glob('*.rb')
          .concat(@globber.glob(ruby_files_glob)).join(' ')
      end
    end
  end
end
