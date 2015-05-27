module Quality
  module Tools
    # Adds 'punchlist' tool support to quality gem
    module Punchlist
      private

      def punchlist_args
        glob = "--glob '#{source_files_glob}'"
        regexp = "--regexp '#{punchlist_regexp}'" if punchlist_regexp

        args = glob
        args += regexp if regexp
        args
      end

      def quality_punchlist
        ratchet_quality_cmd('punchlist',
                            args: punchlist_args) do |_line|
          1
        end
      end
    end
  end
end
