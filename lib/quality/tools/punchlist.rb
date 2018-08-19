# frozen_string_literal: true

module Quality
  module Tools
    # Adds 'punchlist' tool support to quality gem
    class Punchlist < Tool
      def punchlist_args
        glob = "--glob '#{source_and_doc_files_glob}'"
        regexp = " --regexp '#{punchlist_regexp}'" if punchlist_regexp
        unless source_files_exclude_glob == '{}'
          exclude = " --exclude-glob '#{source_files_exclude_glob}'"
        end

        args = glob
        args += regexp if regexp
        args += exclude if exclude
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
