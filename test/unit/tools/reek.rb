module Test
  module Quality
    module Tools
      # Test for the 'reek' tool within the quality gem
      module Reek
        def expect_reek_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('reek',
                                { args: reek_args,
                                  emacs_format: true,
                                  gives_error_code_on_violations: true },
                                'metrics',
                                false)
            .returns(quality_checker)
          expect_find_ruby_files
        end

        private

        def reek_args
          '--single-line fake1.rb fake2.rb ' \
            'features/featuresfake1.rb lib/libfake1.rb test/testfake1.rb'
        end
      end
    end
  end
end
