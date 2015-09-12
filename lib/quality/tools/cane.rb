module Quality
  module Tools
    # Adds 'cane' tool support to quality gem
    module Cane
      private

      def cane_exclude_args
        [
          "--abc-exclude '#{source_files_exclude_glob}'",
          "--style-exclude '#{source_files_exclude_glob}'",
          "--doc-exclude '#{source_files_exclude_glob}'",
        ]
      end

      def cane_args
        args = [
          "-f '#{ruby_files_glob}'",
        ]
        args += cane_exclude_args if exclude_files.size > 0
        args.join(' ')
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
