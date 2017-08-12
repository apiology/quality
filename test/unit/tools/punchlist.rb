# frozen_string_literal: true
module Test
  module Quality
    module Tools
      # Test for the 'bigfiles' tool within the quality gem
      module Punchlist
        def punchlist_expected_args
          "--glob '" + expected_source_and_doc_files_glob +
            "' --regexp 'a|b'" \
            " --exclude-glob '{**/vendor/**,db/schema.rb}'"
        end

        def expect_punchlist_run_with_args(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('punchlist',
                                { args: punchlist_expected_args },
                                'metrics',
                                false,
                                0)
            .returns(quality_checker)
        end

        def expect_punchlist_regexp_pulled
          @mocks[:config]
            .expects(:punchlist_regexp).returns('a|b')
            .at_least(1)
        end

        def expect_source_and_doc_files_glob_pulled
          @mocks[:config]
            .expects(:source_and_doc_files_glob)
            .returns(expected_source_and_doc_files_glob)
            .at_least(1)
        end

        def expect_punchlist_run(quality_checker)
          expect_punchlist_run_with_args(quality_checker)
          expect_punchlist_regexp_pulled
          expect_source_and_doc_files_glob_pulled
          expect_find_exclude_files
        end
      end
    end
  end
end
