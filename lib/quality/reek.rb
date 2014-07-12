module Quality
  module Reek
    private

    def quality_reek
      args = "--single-line #{ruby_files}"
      ratchet_quality_cmd('reek',
                          args: args,
                          emacs_format: true,
                          gives_error_code_on_violations: true) do |line|
        self.class.count_reek_violations(line)
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

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
