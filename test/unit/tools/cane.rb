module Test
  module Quality
    module Tools
      # Test for the 'cane' tool within the quality gem
      module Cane
        def cane_expected_args
          "-f '#{expected_ruby_source_glob}' " \
          "--abc-exclude '{**/vendor/**,db/schema.rb}' " \
          "--style-exclude '{**/vendor/**,db/schema.rb}' " \
          "--doc-exclude '{**/vendor/**,db/schema.rb}'"
        end

        def expect_cane_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('cane',
                                { gives_error_code_on_violations: true,
                                  args: cane_expected_args,
                                  emacs_format: true },
                                'metrics',
                                false)
            .returns(quality_checker)
        end
      end
    end
  end
end
