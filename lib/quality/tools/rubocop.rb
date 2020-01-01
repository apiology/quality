# frozen_string_literal: true

module Quality
  module Tools
    # Adds 'rubocop' tool support to quality gem
    class Rubocop < Tool
      def rubocop_args
        [
          '--force-exclusion',
          '--require rubocop-rspec',
          '--require rubocop-minitest',
          '--format emacs',
          *ruby_files,
        ].join(' ')
      end

      def quality_rubocop
        ratchet_quality_cmd('rubocop',
                            gives_error_code_on_violations: true,
                            args: rubocop_args) do |line|
          self.class.count_rubocop_violations(line)
        end
      end

      def self.count_rubocop_violations(line)
        if line =~ /^.* file[s|] inspected, (.*) offence[s|] detected$/
          0
        elsif line =~ /^warning: .*/
          # don't count internal rubocop errors/warnings
          0
        else
          1
        end
      end
    end
  end
end
