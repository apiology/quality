module Test
  module Quality
    module Tools
      # Test for the 'cane' tool within the quality gem
      module Cane
        def expect_cane_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('cane',
                                { gives_error_code_on_violations: true,
                                  emacs_format: true },
                                'metrics')
            .returns(quality_checker)
          @mocks[:configuration_writer].expects(:exist?).with('.cane')
            .returns(true)
        end
      end
    end
  end
end
