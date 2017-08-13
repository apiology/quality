# frozen_string_literal: true
module Test
  module Quality
    module Tools
      # Test for the 'bigfiles' tool within the quality gem
      module Eslint
        def eslint_expected_args
          '-f unix fake1.js features/featuresfake1.js src/foo/testfake1.js'
        end

        def eslint_quality_checker_args
          [
            'eslint',
            {
              args: eslint_expected_args,
              gives_error_code_on_violations: true,
            },
            'metrics',
            false,
            0,
          ]
        end

        def expect_eslint_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with(*eslint_quality_checker_args)
            .returns(quality_checker)
          expect_find_js_files
        end
      end
    end
  end
end
