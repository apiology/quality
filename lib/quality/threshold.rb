# frozen_string_literal: true

module Quality
  # Calculate threshold for quality gem tool
  class Threshold
    attr_reader :tool_name

    def initialize(tool_name,
                   count_file: File,
                   count_io: IO,
                   output_dir: 'metrics')
      @tool_name = tool_name
      @count_file = count_file
      @count_io = count_io
      @filename = File.join(output_dir, "#{tool_name}_high_water_mark")
    end

    def threshold
      return @count_io.read(@filename).to_i if @count_file.exist?(@filename)
    end

    def write_violations(new_violations)
      @count_file.open(@filename, 'w') do |file|
        file.write(new_violations.to_s + "\n")
      end
    end
  end
end
