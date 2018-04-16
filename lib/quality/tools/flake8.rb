# frozen_string_literal: true

module Quality
  module Tools
    # Adds 'flake8' tool support to quality gem
    module Flake8
      private

      def flake8_args
        python_files.join(' ')
      end

      def flake8_count_errors(line)
        if line =~ /^Usage:/
          # no files specified
          0
        elsif line =~ /^flake8: /
          # no files specified
          0
        elsif line =~ /^$/
          # no files specified
          0
        else
          1
        end
      end

      def quality_flake8
        return if python_files.empty?

        ratchet_quality_cmd('flake8',
                            args: flake8_args,
                            gives_error_code_on_no_relevant_code:
                              true) do |line|
          flake8_count_errors(line)
        end
      end
    end
  end
end
