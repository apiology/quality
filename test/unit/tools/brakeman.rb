# frozen_string_literal: true

module Test
  module Quality
    module Tools
      # Test for the 'bigfiles' tool within the quality gem
      module Brakeman
        def brakeman_expected_args
          '-q --summary -f csv 2>/dev/null'
        end

        def expect_brakeman_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('brakeman',
                                { args: brakeman_expected_args,
                                  gives_error_code_on_no_relevant_code: true },
                                'metrics',
                                false,
                                0)
            .returns(quality_checker)
        end
      end
    end
  end
end
