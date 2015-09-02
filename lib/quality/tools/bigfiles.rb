module Quality
  module Tools
    # Adds 'bigfiles' tool support to quality gem
    module BigFiles
      private

      def quality_bigfiles
        ratchet_quality_cmd('bigfiles',
                            args: "--glob '#{source_files_glob}'") do |line|
          line.split(':')[0].to_i
        end
      end
    end
  end
end
