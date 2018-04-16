# frozen_string_literal: true

module Quality
  module Tools
    # Adds 'bigfiles' tool support to quality gem
    module Mdl
      private

      def mdl_args
        markdown_files.join(' ')
      end

      def quality_mdl
        return if markdown_files.empty?

        ratchet_quality_cmd('mdl',
                            args: mdl_args,
                            gives_error_code_on_violations: true) do |_line|
          1
        end
      end
    end
  end
end
