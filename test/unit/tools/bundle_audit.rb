module Test
  module Quality
    module Tools
      # Test for the 'bundler_audit' tool within the quality gem
      module BundleAudit
        def expect_bundle_audit_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('bundle-audit',
                                {
                                  args: '',
                                  gives_error_code_on_violations: true,
                                },
                                'metrics',
                                false)
            .returns(quality_checker)
        end
      end
    end
  end
end
