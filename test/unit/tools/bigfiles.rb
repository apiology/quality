module Test
  module Quality
    module Tools
      # Test for the 'bigfiles' tool within the quality gem
      module BigFiles
        def expect_bigfiles_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('bigfiles',
                                {},
                                'metrics',
                                false)
            .returns(quality_checker)
        end
      end
    end
  end
end
