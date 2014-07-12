module Quality
  private

  module Cane
    def write_out_dot_cane
      @configuration_writer.open('.cane', 'w') do |file|
        file.write('-f **/*.rb')
      end
    end

    def quality_cane
      write_out_dot_cane unless @configuration_writer.exist?('.cane')

      ratchet_quality_cmd('cane',
                          gives_error_code_on_violations: true,
                          emacs_format: true) do |line|
        if line =~ /\(([0-9]*)\):$/
          Regexp.last_match[1].to_i
        else
          0
        end
      end
    end
  end
end
