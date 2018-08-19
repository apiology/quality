# frozen_string_literal: true

module Quality
  module Tools
    # Adds 'bigfiles' tool support to quality gem
    class Mdl < Tool
      def mdl_args
        markdown_files.join(' ')
      end

      def quality_mdl
        if mdl_args.empty?
          puts 'No markdown files found--skipping mdl'
          return
        end

        ratchet_quality_cmd('mdl',
                            args: mdl_args,
                            gives_error_code_on_violations: true) do |line|
          if line =~ /\d: MD/
            1
          else
            0
          end
        end
      end
    end
  end
end
