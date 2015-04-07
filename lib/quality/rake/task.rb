#!/usr/bin/env ruby

require 'rake'
require 'rake/tasklib'
require 'rbconfig'
require_relative '../runner'
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

      # Log command executation
      #
      # Defaults to false
      attr_accessor :verbose

      # Array of directory names which contain ruby files to analyze.
      #
      # Defaults to %w(app lib test spec feature), which translates to *.rb in
      # the base directory, as well as those directories.
      attr_writer :ruby_dirs

      # Array of directory names which contain any type of source
      # files to analyze.
      #
      # Defaults to the same as ruby_dirs
      attr_writer :source_dirs

      # Relative path to output directory where *_high_water_mark
      # files will be read/written
      #
      # Defaults to .
      attr_accessor :output_dir

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
        @dsl, @cmd_runner = dsl, cmd_runner
        @globber = globber
        @quality_name, @ratchet_name = quality_name, ratchet_name

        @skip_tools = []

        @verbose = false

        @output_dir = 'metrics'

        yield self if block_given?

        @runner = Quality::Runner.new(self,
                                      gem_spec: gem_spec,
                                      quality_checker_class:
                                        quality_checker_class,
                                      count_io: count_io,
                                      count_file: count_file)
        define
      end

      attr_reader :globber

      def ruby_dirs
        @ruby_dirs ||= %w(app lib test spec feature)
      end

      def source_dirs
        @source_dirs ||= ruby_dirs.clone
      end

      def source_files_glob(extensions = 'rb,swift,cpp,c,java,py')
        File.join("{#{source_dirs.join(',')}}",
                  '**', "*.{#{extensions}}")
      end

      def ruby_files_glob
        source_files_glob('rb')
      end

      def ruby_files
        @globber.glob('{*.rb,Rakefile}')
          .concat(@globber.glob(ruby_files_glob)).join(' ')
      end

      private

      def define # :nodoc:
        desc 'Verify quality has increased or stayed ' \
             'the same' unless ::Rake.application.last_comment
        @dsl.define_task(quality_name) { @runner.run_quality }
        @dsl.define_task(ratchet_name) { @runner.run_ratchet }
        @runner.tools.each do |tool|
          @dsl.define_task(tool) { @runner.run_quality_with_tool(tool) }
        end
      end
    end
  end
end
