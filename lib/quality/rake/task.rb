#!/usr/bin/env ruby

require 'rake'
require 'rake/tasklib'
require 'rbconfig'

module Quality

  #
  # Defines a task library for running quality's various tools
  # (Classes here will be configured via the Rakefile, and therefore will
  # possess a :reek:attribute or two.)
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
      attr_accessor :name

      # Array of strings describing tools to be skipped--e.g., ["cane"]
      #
      # Defaults to []
      attr_accessor :skip_tools

      # Array of directory names which contain ruby files to analyze.
      #
      # Defaults to %w{lib test features}, which translates to *.rb in the base directory, as well as lib, test, and features.
      attr_writer :ruby_dirs

      # Defines a new task, using the name +name+.
      def initialize(args = {})
        @name = args[:name]
        @name = 'quality' if @name.nil?
        @skip_tools = [] if @skip_tools.nil?
        @config_files = nil
        @source_files = nil
        @ruby_opts = []
        @reek_opts = ''
        @fail_on_error = true
        @sort = nil

        yield self if block_given?
        @config_files ||= 'config/**/*.reek'
        @source_files ||= 'lib/**/*.rb'
        define
      end

  private

      def define # :nodoc:
        desc 'Verify quality has increased or stayed ' +
          'the same' unless ::Rake.application.last_comment
        task(name) { run_task }
        self
      end

      def run_task
        tools = ['cane', 'flog', 'flay', 'reek', 'rubocop']
        tools.each do |tool|
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
      end

      def ratchet_quality_cmd(cmd,
                              options,
                              &process_output_line)

        gives_error_code_on_violations ||= options[:gives_error_code_on_violations]
        args ||= options[:args]
        emacs_format ||= options[:emacs_format]

        violations = 0
        out = ""
        found_output = false
        if defined?(RUBY_ENGINE) && (RUBY_ENGINE == 'jruby')
          full_cmd = "jruby -S #{cmd}"
        elsif RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
          full_cmd = "#{cmd}.bat"
        else
          full_cmd = cmd
        end

        if !args.nil?
          full_cmd = "#{full_cmd} #{args}"
        end

        IO.popen(full_cmd) do |f|
          while line = f.gets
            if emacs_format
              if line =~ /^ *(\S*.rb:[0-9]*) *(.*)/
                out << $1 << ": " << $2 << "\n"
              elsif line =~ /^ *(.*) +(\S*.rb:[0-9]*) *(.*)/
                out << $2 << ": " << $1 << "\n"
              else
                out << line
              end
            else
              out << line
            end
            found_output = true
            violations += yield line
          end
        end
        exit_status = $?.exitstatus
        if !gives_error_code_on_violations
          if exit_status != 0
            fail "Error detected running #{full_cmd}.  Exit status is #{exit_status}, output is [#{out}]"
          end
        end
        filename = "#{cmd}_high_water_mark"
        if File.exist?(filename)
          existing_violations = IO.read(filename).to_i
        else
          existing_violations = 9999999999
        end
        puts "Existing violations: #{existing_violations}"
        puts "Found #{violations} #{cmd} violations"
        if violations > existing_violations
          fail "Output from #{cmd}\n\n#{out}\n\n" +
            "Reduce total number of #{cmd} violations to #{existing_violations} or below!"
        elsif violations < existing_violations
          puts "Ratcheting quality up..."
          File.open(filename, 'w') {|f| f.write(violations.to_s) }
        end
      end

      def quality_cane
        if ! File.exist?(".cane")
          File.open(".cane", "w") {|f| f.write("-f **/*.rb")}
        end
        ratchet_quality_cmd("cane",
                            gives_error_code_on_violations: true,
                            emacs_format: true) { |line|
          if line =~ /\(([0-9]*)\):$/
            $1.to_i
          else
            0
          end
        }
      end

      def ruby_dirs
        @ruby_dirs ||= %w{lib test features}
      end

      def ruby_files
        Dir.glob('*.rb').concat(Dir.glob(File.join("{#{ruby_dirs.join(',')}}", '**', '*.rb'))).join(' ')
      end

      def quality_reek
        args = "--line-number #{ruby_files}"
        ratchet_quality_cmd("reek",
                            args: args,
                            emacs_format: true,
                            gives_error_code_on_violations: true) { |line|
          if line =~ /^  .* (.*)$/
            1
          else
            0
          end
        }
      end

      def quality_flog
        threshold = 50
        ratchet_quality_cmd("flog",
                            args: "--all --continue --methods-only #{ruby_files}",
                            emacs_format: true) { |line|
          if line =~ /^ *([0-9.]*): flog total$/
            0
            #$1.to_i
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
        }
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
                            args: "--format emacs #{ruby_files}") { |line|
          if line =~ /^.* file[s|] inspected, (.*) offence[s|] detected$/
            0
          else
            1
          end
        }
      end

      def quality
        Dir.glob("*_high_water_mark").each { |filename|
          puts "Processing #{filename}"
          existing_violations = IO.read(filename).to_i
          if existing_violations <= 0
            raise "Problem with file #{filename}"
          end
          new_violations = existing_violations - 1
          File.open(filename, 'w') {|f| f.write(new_violations.to_s) }
          system("git commit -m 'tighten quality standard' #{filename}")
        }
      end
    end
  end
end
