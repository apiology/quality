#!/usr/bin/env ruby

require 'rake'
require 'rake/tasklib'
require 'rbconfig'
require_relative '../runner'
require_relative '../quality_checker'
require_relative 'config'

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
      # Defines a new task, using the name +name+.
      def initialize(dsl: ::Rake::Task,
                     cmd_runner: Kernel,
                     count_file: File,
                     count_io: IO,
                     globber: Dir,
                     gem_spec: Gem::Specification,
                     quality_checker_class:
                       Quality::QualityChecker)
        @dsl, @cmd_runner = dsl, cmd_runner
        @globber = globber
        @config = Quality::Config.new(globber: globber)
        yield @config if block_given?
        @runner = Quality::Runner.new(@config,
                                      gem_spec: gem_spec,
                                      quality_checker_class:
                                        quality_checker_class,
                                      count_io: count_io,
                                      count_file: count_file,
                                      globber: globber)
        define
      end

      attr_reader :globber, :config

      private

      def define
        desc 'Verify quality has increased or stayed ' \
             'the same' unless ::Rake.application.last_comment
        puts "adding task #{config.quality_name}"
        puts "adding task #{config.ratchet_name}"
        @dsl.define_task(config.quality_name) { @runner.run_quality }
        @dsl.define_task(config.ratchet_name) { @runner.run_ratchet }
        @runner.tools.each do |tool|
          @dsl.define_task(tool) { @runner.run_quality_with_tool(tool) }
        end
      end
    end
  end
end
