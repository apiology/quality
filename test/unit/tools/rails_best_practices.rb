# frozen_string_literal: true

module Test
  module Quality
    module Tools
      # Test for the 'bigfiles' tool within the quality gem
      module RailsBestPractices
        def expect_rails_best_practices_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('rails_best_practices',
                                { gives_error_code_on_violations: true },
                                'metrics',
                                false,
                                0)
            .returns(quality_checker)
        end
      end
    end
  end
end
