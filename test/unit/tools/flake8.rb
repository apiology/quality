# frozen_string_literal: true
module Test
  module Quality
    module Tools
      # Test for the 'bigfiles' tool within the quality gem
      module Flake8
        def flake8_expected_args
          'fake1.py'
        end

        def expect_flake8_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('flake8',
                                { args: flake8_expected_args,
                                  gives_error_code_on_no_relevant_code: true },
                                'metrics',
                                false,
                                0)
            .returns(quality_checker)
          expect_find_python_files
        end
      end
    end
  end
end
