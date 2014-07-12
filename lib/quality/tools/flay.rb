module Quality
  module Tools
    module Flay

      private

      def quality_flay
        ratchet_quality_cmd('flay',
                            args: "-m 75 -t 99999 #{ruby_files}",
                            emacs_format: true) do |line|
          if line =~ /^[0-9]*\).* \(mass = ([0-9]*)\)$/
            Regexp.last_match[1].to_i
          else
            0
          end
        end
      end
    end
  end
end
