# frozen_string_literal: true

module Quality
  module Tools
    # Adds 'rubocop' tool support to quality gem
    module Brakeman
      private

      def quality_brakeman
        ratchet_quality_cmd('brakeman',
                            args: '-q --summary -f csv 2>/dev/null',
                            gives_error_code_on_no_relevant_code:
                              true) do |line|
          if line =~ /Security Warnings,([0-9]*) \([0-9]*\)$/
            Regexp.last_match[1].to_i
          else
            0
          end
        end
      end
    end
  end
end
