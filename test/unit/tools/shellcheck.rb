# frozen_string_literal: true
module Test
  module Quality
    module Tools
      # Test for the 'shellcheck' tool within the quality gem
      module Shellcheck
        def shellcheck_expected_args
          '-fgcc -sbash fake1.sh'
        end

        def expect_shellcheck_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('shellcheck',
                                { args: shellcheck_expected_args,
                                  gives_error_code_on_no_relevant_code: true,
                                  gives_error_code_on_violations: true },
                                'metrics',
                                false,
                                0)
            .returns(quality_checker)
          expect_find_shell_files
        end
      end
    end
  end
end
