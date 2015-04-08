module Quality
  module Tools
    # Adds 'punchlist' tool support to quality gem
    module Punchlist
      private

      def quality_punchlist
        ratchet_quality_cmd('punchlist',
                            args: "--glob '#{source_files_glob}'") do |line|
          1
        end
      end
    end
  end
end
