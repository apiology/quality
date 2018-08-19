# frozen_string_literal: true

module Quality
  module Tools
    # Adds 'bigfiles' tool support to quality gem
    class Bigfiles < Tool
      def bigfiles_args
        args = ['--glob', "'#{source_and_doc_files_glob}'"]
        unless source_files_exclude_glob == '{}'
          args << ['--exclude-glob', "'#{source_files_exclude_glob}'"]
        end
        args.join(' ')
      end

      def quality_bigfiles
        ratchet_quality_cmd('bigfiles',
                            args: bigfiles_args) do |line|
          line.split(':')[0].to_i
        end
      end
    end
  end
end
