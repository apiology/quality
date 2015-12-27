module Test
  module Quality
    module Tools
      # Test for the 'flay' tool within the quality gem
      module Flay
        def expect_flay_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('flay',
                                { args: flay_args,
                                  emacs_format: true },
                                'metrics',
                                false)
            .returns(quality_checker)
          expect_find_ruby_files
        end

        private

        def flay_args
          '--mass 75 --timeout 99999 ' \
            'fake1.rb fake2.rb features/featuresfake1.rb lib/libfake1.rb ' \
            'test/testfake1.rb'
        end
      end
    end
  end
end
