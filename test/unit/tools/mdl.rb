# frozen_string_literal: true

module Test
  module Quality
    module Tools
      # Test for the 'mdl' tool within the quality gem
      module Mdl
        def mdl_expected_args
          'file1.md file2.md'
        end

        def mdl_quality_checker_args
          [
            'mdl',
            {
              args: mdl_expected_args,
              gives_error_code_on_violations: true,
            },
            'metrics',
            false,
            0,
          ]
        end

        def expect_mdl_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with(*mdl_quality_checker_args)
            .returns(quality_checker)
          expect_find_markdown_files
        end
      end
    end
  end
end
