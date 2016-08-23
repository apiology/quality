module Quality
  module Tools
    # Adds 'bundler_audit' tool support to quality gem
    module BundleAudit
      def self.command_name
        'bundle-audit'
      end

      private

      def quality_bundle_audit
        ratchet_quality_cmd('bundle-audit',
                            args: '',
                            gives_error_code_on_violations: true) do |line|
          if line =~ /^Name: /
            1
          else
            0
          end
        end
      end
    end
  end
end
