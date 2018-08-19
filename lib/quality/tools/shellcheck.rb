# frozen_string_literal: true

module Quality
  module Tools
    # Adds 'ShellCheck' tool support to quality gem
    class Shellcheck < Tool
      def shellcheck_args
        "-fgcc -sbash #{shell_files.join(' ')}"
      end

      def quality_shellcheck
        ratchet_quality_cmd('shellcheck',
                            args: shellcheck_args,
                            gives_error_code_on_no_relevant_code: true,
                            gives_error_code_on_violations: true)
      end
    end
  end
end
