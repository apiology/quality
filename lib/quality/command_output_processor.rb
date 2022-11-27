# frozen_string_literal: true

module Quality
  # Class processes output from a code quality command, tweaking it
  # for editor output and counting the number of violations found
  class CommandOutputProcessor
    attr_accessor :emacs_format, :file
    attr_reader :found_output, :violations

    def initialize
      @emacs_format = false
      @found_output = false
      @violations = 0
    end

    def process(&count_violations_on_line)
      process_file(file, &count_violations_on_line)
    end

    private

    def process_file(file, &count_violations_on_line)
      out = ''
      out += process_line(&count_violations_on_line) while (@current_line = file.gets)
      out
    end

    def processed_output
      if emacs_format
        preprocess_line_for_emacs
      else
        @current_line
      end
    end

    def process_line(&block)
      @found_output = true
      @violations += if block
                       yield @current_line
                     else
                       1
                     end
      processed_output
    end

    def preprocess_line_for_emacs
      case @current_line
      when /^ *(\S*.rb:[0-9]*) *(.*)/
        "#{Regexp.last_match[1]}: #{Regexp.last_match[2]}\n"
      when /^ *(.*) +(\S*.rb:[0-9]*) *(.*)/
        "#{Regexp.last_match[2]}: #{Regexp.last_match[1]}\n"
      else
        @current_line
      end
    end
  end
end
