# frozen_string_literal: true
module Test
  module Quality
    module Tools
      # Test for the 'bigfiles' tool within the quality gem
      module Bigfiles
        def expected_source_files_glob
          '{fake1.py,README.md}'
        end

        def bigfiles_expected_args
          "--glob '" + expected_source_files_glob + "' " \
          "--exclude-glob '{**/vendor/**,db/schema.rb}'"
        end

        def expect_bigfiles_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('bigfiles',
                                { args: bigfiles_expected_args },
                                'metrics',
                                false,
                                300)
            .returns(quality_checker)
          expect_find_source_files
          expect_find_exclude_glob
        end
      end
    end
  end
end
