# frozen_string_literal: true

module Quality
  module Tools
    # Adds 'bigfiles' tool support to quality gem
    module Eslint
      private

      def eslint_args
        '-f unix ' + js_files.join(' ')
      end

      def quality_eslint
        return if js_files.empty?

        ratchet_quality_cmd('eslint',
                            args: eslint_args,
                            gives_error_code_on_violations: true) do |line|
          if line =~ /^.*:\d+:\d+: /
            1
          else
            0
          end
        end
      end
    end
  end
end
