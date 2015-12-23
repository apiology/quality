module Quality
  module Tools
    # Adds 'pep8' tool support to quality gem
    module Pep8
      private

      def pep8_args
        python_files.join(' ')
      end

      def quality_pep8
        ratchet_quality_cmd('pep8',
                            args: pep8_args) do |line|
          line.split(':')[0].to_i
        end
      end
    end
  end
end
