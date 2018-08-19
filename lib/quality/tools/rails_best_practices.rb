# frozen_string_literal: true

module Quality
  module Tools
    # Adds 'rubocop' tool support to quality gem
    class RailsBestPractices < Tool
      def quality_rails_best_practices
        ratchet_quality_cmd('rails_best_practices',
                            gives_error_code_on_violations: true) do |line|
          self.class.count_rails_best_practices_violations(line)
        end
      end

      # See Rubocop.included
      def self.count_rails_best_practices_violations(line)
        if line =~ /.*:[0-9]* - /
          1
        else
          0
        end
      end
    end
  end
end
