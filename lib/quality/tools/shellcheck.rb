# frozen_string_literal: true

module Quality
  module Tools
    # Adds 'ShellCheck' tool support to quality gem
    module Shellcheck
      private

      def shellcheck_args
        "-fgcc -sbash #{shell_files.join(' ')}"
      end

      def quality_shellcheck
        return if shell_files.empty?

        ratchet_quality_cmd('shellcheck',
                            args: shellcheck_args,
                            gives_error_code_on_no_relevant_code: true,
                            gives_error_code_on_violations: true)
      end
    end
  end
end
