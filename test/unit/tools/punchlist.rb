module Test
  module Quality
    module Tools
      # Test for the 'bigfiles' tool within the quality gem
      module Punchlist
        def punchlist_expected_args
          "--glob '" + expected_source_and_doc_files_glob +
            "' --exclude-glob '{**/vendor/**,db/schema.rb}'"
        end

        def expect_punchlist_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('punchlist',
                                { args: punchlist_expected_args },
                                'metrics',
                                false)
            .returns(quality_checker)
        end
      end
    end
  end
end
