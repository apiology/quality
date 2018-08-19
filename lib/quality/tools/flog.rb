# frozen_string_literal: true

module Quality
  module Tools
    # Adds 'flog' tool support to quality gem
    class Flog < Tool
      def quality_flog
        args = "--all --continue --methods-only #{ruby_files.join(' ')}"
        ratchet_quality_cmd('flog', args: args, emacs_format: true) do |line|
          self.class.count_violations_in_flog_output(line)
        end
      end

      def self.count_violations_in_flog_output(line, threshold = 50)
        return 0 if line =~ /^ *([0-9.]*): flog total$/

        return 0 unless line =~ /^ *([0-9.]*): (.*) .*.rb:[0-9]*$/

        score = Regexp.last_match[1].to_i

        return 1 if score > threshold

        0
      end
    end
  end
end
