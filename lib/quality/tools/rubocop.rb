# frozen_string_literal: true

module Quality
  module Tools
    # Adds 'rubocop' tool support to quality gem
    module Rubocop
      def self.included(base)
        base.extend ClassMethods
      end

      private

      def rubocop_args
        [
          '--force-exclusion',
          '--require rubocop-rspec',
          '--format emacs',
          *ruby_files,
        ].join(' ')
      end

      def quality_rubocop
        return if ruby_files.empty?

        ratchet_quality_cmd('rubocop',
                            gives_error_code_on_violations: true,
                            args: rubocop_args) do |line|
          self.class.count_rubocop_violations(line)
        end
      end

      # See Rubocop.included
      module ClassMethods
        def count_rubocop_violations(line)
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
end
