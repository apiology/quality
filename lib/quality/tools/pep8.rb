# frozen_string_literal: true

module Quality
  module Tools
    # Adds 'pep8' tool support to quality gem
    module Pep8
      private

      def pep8_args
        python_files.join(' ')
      end

      def pep8_count_errors(line)
        if line =~ /^Usage:/
          # no files specified
          0
        elsif line =~ /^pep8: /
          # no files specified
          0
        elsif line =~ /^$/
          # no files specified
          0
        else
          1
        end
      end

      def quality_pep8
        ratchet_quality_cmd('pep8',
                            args: pep8_args,
                            gives_error_code_on_no_relevant_code:
                              true) do |line|
          pep8_count_errors(line)
        end
      end
    end
  end
end
