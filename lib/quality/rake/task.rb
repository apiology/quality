#!/usr/bin/env ruby

require 'rake'
require 'rake/tasklib'

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

      # Name of reek task.
      # Defaults to :reek.
      attr_accessor :name

      # Array of directories to be added to $LOAD_PATH before running reek.
      # Defaults to ['<the absolute path to reek's lib directory>']
      attr_accessor :libs

      # Use verbose output. If this is set to true, the task will print
      # the reek command to stdout. Defaults to false.
      attr_accessor :verbose

      # Defines a new task, using the name +name+.
      def initialize(args = {})
        @name = args[:name]
        @name = 'quality' if @name.nil?
        @libs = [File.expand_path(File.dirname(__FILE__) + '/../../../lib')]
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
        quality_cane
        quality_reek
        quality_flog
        quality_flay
        quality_rubocop
      end
      
      def ratchet_quality_cmd(cmd,
                              options,
                              &process_output_line)

        args ||= options[:args]
        emacs_format ||= options[:emacs_format]

        violations = 0
        out = ""
        found_output = false
        full_cmd = cmd
        if !args.nil?
          full_cmd = "#{cmd} #{args}"
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
        if !found_output
          fail "#{full_cmd} execution failed!  Exit status is #{exit_status}"
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
          File.open(".cane", "w") {|f| f.write("-f *.rb lib/*.rb test/*.rb")}
        end        
        ratchet_quality_cmd("cane",
                            emacs_format: true) { |line|
          if line =~ /\(([0-9]*)\):$/
            $1.to_i
          else
            0
          end
        }
      end

      def quality_reek
        ratchet_quality_cmd("reek",
                            args: "--line-number *.rb lib/*.rb 2>/dev/null",
                            emacs_format: true) { |line|
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
                            args: "--all --continue --methods-only . 2>/dev/null",
                            emacs_format: true) { |line|
          if line =~ /^ *([0-9.]*): flog total$/
            0
            #$1.to_i
          elsif line =~ /^ *([0-9.]*): (.*) .\/.*.rb:[0-9]*$/
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
                            args: "-t 99999 . 2>/dev/null",
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
                            args: "--format emacs 2>&1") { |line|
          if line =~ /^.* files inspected, (.*) offences detected$/
            $1.to_i
          else
            0
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
