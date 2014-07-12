module Test
  module Quality
    module Tools
      module Rubocop
        def expect_rubocop_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('rubocop',
          { args: rubocop_args,
            gives_error_code_on_violations: true },
            '.')
            .returns(quality_checker)
          expect_find_ruby_files
          expect_installed('rubocop')
        end

        private

        def rubocop_args
          '--format emacs fake1.rb fake2.rb lib/libfake1.rb ' \
            'test/testfake1.rb features/featuresfake1.rb'
        end
      end
    end
  end
end
