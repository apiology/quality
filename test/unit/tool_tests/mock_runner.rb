# Acts as the 'Runner' class for testing the tool plug-in modules
class MockRunner
  include Quality::Tools::Pep8
  include Quality::Tools::Flake8
  include Quality::Tools::Jscs
  def initialize(lines)
    @lines = lines
  end

  attr_accessor :sum, :lines

  def python_files
    []
  end

  def js_files
    []
  end

  def ratchet_quality_cmd(_name,
                          _options,
                          &_block)
    @sum = 0
    lines.each do |line|
      @sum += yield line
    end
  end

  def run(tool_name)
    method("quality_#{tool_name}").call
    sum
  end
end
