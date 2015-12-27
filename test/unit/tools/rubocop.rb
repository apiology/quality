module Test
  module Quality
    module Tools
      # Test for the 'rubocop' tool within the quality gem
      module Rubocop
        def expect_rubocop_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('rubocop',
                                { args: rubocop_args,
                                  gives_error_code_on_violations: true },
                                'metrics',
                                false)
            .returns(quality_checker)
          expect_find_ruby_files
        end

        private

        def rubocop_args
          '--require rubocop-rspec --format emacs fake1.rb fake2.rb ' \
          'features/featuresfake1.rb lib/libfake1.rb test/testfake1.rb'
        end
      end
    end
  end
end
