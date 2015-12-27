module Test
  module Quality
    module Tools
      # Test for the 'flog' tool within the quality gem
      module Flog
        def expect_flog_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('flog',
                                { args: flog_args,
                                  emacs_format: true },
                                'metrics',
                                false)
            .returns(quality_checker)
          expect_find_ruby_files
        end

        private

        def flog_args
          '--all --continue --methods-only ' \
            'fake1.rb fake2.rb features/featuresfake1.rb lib/libfake1.rb ' \
            'test/testfake1.rb'
        end
      end
    end
  end
end
