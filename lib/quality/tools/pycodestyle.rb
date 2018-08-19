# frozen_string_literal: true

module Quality
  module Tools
    # Adds 'pycodestyle' tool support to quality gem
    class Pycodestyle < Tool
      def pycodestyle_args
        python_files.join(' ')
      end

      def pycodestyle_count_errors(line)
        if line =~ /^Usage:/
          # no files specified
          0
        elsif line =~ /^pycodestyle: /
          # no files specified
          0
        elsif line =~ /^$/
          # no files specified
          0
        else
          1
        end
      end

      def quality_pycodestyle
        ratchet_quality_cmd('pycodestyle',
                            args: pycodestyle_args,
                            gives_error_code_on_no_relevant_code:
                              true) do |line|
          pycodestyle_count_errors(line)
        end
      end
    end
  end
end
