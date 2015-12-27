module Quality
  module Tools
    # Adds 'bigfiles' tool support to quality gem
    module Jscs
      private

      def jscs_args
        '-r unix ' + js_files_arr.join(' ')
      end

      def quality_jscs
        ratchet_quality_cmd('jscs',
                            args: jscs_args,
                            gives_error_code_on_violations: true) do |line|
          if line =~ /^.*:\d+:\d+: /
            1
          else
            0
          end
        end
      end
    end
  end
end
