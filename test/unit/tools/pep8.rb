module Test
  module Quality
    module Tools
      # Test for the 'bigfiles' tool within the quality gem
      module Pep8
        def pep8_expected_args
          'fake1.py'
        end

        def expect_pep8_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('pep8',
                                { args: pep8_expected_args,
                                  gives_error_code_on_no_relevant_code: true },
                                'metrics',
                                false)
            .returns(quality_checker)
          expect_find_python_files
        end
      end
    end
  end
end
