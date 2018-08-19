# frozen_string_literal: true

# Acts as the 'Runner' class for testing the tool plug-in modules
class MockRunner
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

  CHECKER = {
    flake8: Quality::Tools::Flake8,
    pycodestyle: Quality::Tools::Pycodestyle,
    jscs: Quality::Tools::Jscs,
  }.freeze

  def run(tool_name)
    CHECKER[tool_name.to_sym].new(self).method("quality_#{tool_name}").call
    sum
  end
end
