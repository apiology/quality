module Test
  module Quality
    module Tools
      module Flog
        def expect_flog_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('flog',
          { args: flog_args,
            emacs_format: true },
            '.')
            .returns(quality_checker)
          expect_find_ruby_files
          expect_installed('flog')
        end

        private

        def flog_args
          '--all --continue --methods-only ' \
            'fake1.rb fake2.rb lib/libfake1.rb ' \
            'test/testfake1.rb features/featuresfake1.rb'
        end
      end
    end
  end
end
