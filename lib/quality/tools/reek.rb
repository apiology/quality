# frozen_string_literal: true

module Quality
  module Tools
    # Adds 'reek' tool support to quality gem
    module Reek
      def self.included(base)
        base.extend ClassMethods
      end

      private

      def quality_reek
        return if ruby_files.empty?

        args = "--single-line #{ruby_files.join(' ')}"
        ratchet_quality_cmd('reek',
                            args: args,
                            emacs_format: true,
                            gives_error_code_on_violations: true) do |line|
          self.class.count_reek_violations(line)
        end
      end

      # See Reek.included
      module ClassMethods
        def count_reek_violations(line)
          if line =~ /^  .* (.*)$/
            1
          else
            0
          end
        end
      end
    end
  end
end
