# frozen_string_literal: true

module Quality
  module Tools
    # Adds 'bigfiles' tool support to quality gem
    class Jscs < Tool
      def jscs_args
        '-r unix ' + js_files.join(' ')
      end

      def jscs_check_configured
        return 0 if js_files.empty?

        puts 'No JSCS config found!  To generate one, run ' \
             'jscs --auto-configure representative_file.js'
        0
      end

      def jscs_count_violations_on_line(line)
        if line =~ /^.*:\d+:\d+: /
          1
        elsif line =~ /^No configuration found/
          jscs_check_configured
        else
          0
        end
      end

      def quality_jscs
        ratchet_quality_cmd('jscs',
                            args: jscs_args,
                            gives_error_code_on_violations: true) do |line|
          jscs_count_violations_on_line(line)
        end
      end
    end
  end
end
