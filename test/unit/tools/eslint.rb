module Test
  module Quality
    module Tools
      # Test for the 'bigfiles' tool within the quality gem
      module Eslint
        def eslint_expected_args
          '-f unix fake1.js features/featuresfake1.js src/foo/testfake1.js'
        end

        def expect_eslint_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('eslint',
                                {
                                  args: eslint_expected_args,
                                  gives_error_code_on_violations: true
                                },
                                'metrics',
                                false)
            .returns(quality_checker)
          expect_find_js_files
        end
      end
    end
  end
end
