module Test
  module Quality
    module Tools
      # Test for the 'bigfiles' tool within the quality gem
      module Jscs
        def jscs_expected_args
          '-r unix fake1.js features/featuresfake1.js src/foo/testfake1.js'
        end

        def expect_jscs_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('jscs',
                                { args: jscs_expected_args,
                                  gives_error_code_on_violations: true },
                                'metrics',
                                false)
            .returns(quality_checker)
          expect_find_js_files
        end
      end
    end
  end
end
