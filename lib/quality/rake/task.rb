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
        @dsl = args[:dsl]

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
        @reek_opts = ''
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
        if @dsl.nil?
          task(quality_name) { run_quality }
          task(ratchet_name) { run_ratchet }
        else
          @dsl.task(quality_name) { run_quality }
          @dsl.task(ratchet_name) { run_ratchet }
        end
      end

      def run_quality
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

      def run_ratchet
        @globber.glob("*_high_water_mark").each { |filename|
          puts "Processing #{filename}"
          existing_violations = @count_io.read(filename).to_i
          if existing_violations < 0
            raise "Problem with file #{filename}"
          end
          new_violations = [0, existing_violations - 1].max
          @count_file.open(filename, 'w') {|f| f.write(new_violations.to_s) }
          if new_violations != existing_violations
            @cmd_runner.system("git commit -m 'tighten quality standard' #{filename}")
          end
        }
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

        @popener.popen(full_cmd) do |f|
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
        filename = File.join(@output_dir, "#{cmd}_high_water_mark")
        if @count_file.exist?(filename)
          existing_violations = @count_io.read(filename).to_i
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
          @count_file.open(filename, 'w') do |f|
            f.write(violations.to_s)
          end
        end
      end

      def quality_cane
        if ! @configuration_writer.exist?(".cane")
          @configuration_writer.open(".cane", "w") {|f| f.write("-f **/*.rb")}
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
        @globber.glob('*.rb').concat(@globber.glob(File.join("{#{ruby_dirs.join(',')}}", '**', '*.rb'))).join(' ')
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

    end
  end
end
