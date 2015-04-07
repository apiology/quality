module Quality
  module Tools
    # Adds 'cane' tool support to quality gem
    module Cane
      private

      def cane_args
        "-f '#{ruby_files_glob}'"
      end

      def quality_cane
        ratchet_quality_cmd('cane', gives_error_code_on_violations: true,
                                    args: cane_args,
                                    emacs_format: true) do |line|
          if line =~ /\(([0-9]*)\):$/
            Regexp.last_match[1].to_i
          else
            0
          end
        end
      end
    end
  end
end
