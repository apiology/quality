require_relative 'tools/cane'
require_relative 'tools/flay'
require_relative 'tools/flog'
require_relative 'tools/reek'
require_relative 'tools/rubocop'

# Unit test the Task class
class TestTask < Test::Unit::TestCase
  include ::Test::Quality::Tools::Cane
  include ::Test::Quality::Tools::Flay
  include ::Test::Quality::Tools::Flog
  include ::Test::Quality::Tools::Reek
  include ::Test::Quality::Tools::Rubocop

  def test_quality_task
    get_test_object do
      setup_quality_task_mocks
    end
  end

  def setup_quality_task_mocks
    expect_tools_tasks_defined
    expect_define_task.with('quality').yields
    expect_define_task.with('ratchet')
    expect_tools_run
  end

  def expect_tools_tasks_defined
    all_tools.each do |tool|
      expect_define_task.with(tool)
    end
  end

  def all_tools
    %w(cane flog flay reek rubocop)
  end

  def expect_tools_run
    all_tools.each do |tool_name|
      puts "Looking at #{tool_name}"
      expect_single_tool_run(tool_name)
    end
  end

  def expect_single_tool_run(tool_name)
    quality_checker = mock('quality_checker')
    method("expect_#{tool_name}_run").call(quality_checker)
    file = self.class.sample_output(tool_name)
    lines = file.lines.map { |line| line.strip }
    quality_checker.expects(:execute).multiple_yields(*lines)
  end

  def test_ratchet_task
    get_test_object do
      setup_ratchet_task_mocks
    end
  end

  def expect_define_task
    @mocks[:dsl].expects(:define_task)
  end

  def setup_ratchet_task_mocks
    expect_tools_tasks_defined
    expect_define_task.with('quality')
    expect_define_task.with('ratchet').yields
    @mocks[:globber].expects(:glob)
      .with('./*_high_water_mark').returns(%w(./foo_high_water_mark
                                              ./bar_high_water_mark))
    expect_ratchet('foo', 12)
    expect_ratchet('bar', 96)
  end

  def expect_ratchet(tool_name, old_high_water_mark)
    filename = "./#{tool_name}_high_water_mark"
    expect_read_from_high_water_mark(filename, old_high_water_mark)
    expect_write_to_high_water_mark(filename, old_high_water_mark - 1)
    @mocks[:cmd_runner].expects(:system)
      .with("git commit -m 'tighten quality standard' #{filename}")
  end

  def expect_read_from_high_water_mark(filename, old_high_water_mark)
    @mocks[:count_io].expects(:read).with(filename)
      .returns(old_high_water_mark.to_s)
  end

  def expect_write_to_high_water_mark(filename, new_high_water_mark)
    file = mock('file')
    @mocks[:count_file].expects(:open).with(filename, 'w').yields(file)
    file.expects(:write).with(new_high_water_mark.to_s + "\n")
  end

  def expect_installed(tool_name)
    @mocks[:gem_spec].expects(:find_all_by_name)
      .with(tool_name).returns([true])
  end

  def self.sample_output(tool_name)
    IO.read("#{File.dirname(__FILE__)}/samples/#{tool_name}_sample_output")
  end

  def expect_find_ruby_files
    expect_glob.with('*.rb').returns(['fake1.rb', 'fake2.rb'])
    expect_glob.with('{lib,test,spec,feature}/**/*.rb')
      .returns(['lib/libfake1.rb',
                'test/testfake1.rb',
                'features/featuresfake1.rb'])
  end

  def expect_glob
    @mocks[:globber].expects(:glob)
  end

  def test_mocks
    {
      dsl: mock('dsl'),
      cmd_runner: mock('cmd_runner'),
      globber: mock('globber'),
      count_io: mock('count_io'),
      count_file: mock('count_file'),
      configuration_writer: mock('configuration_writer'),
      gem_spec: mock('gem_spec'),
      quality_checker_class: mock('quality_checker_class')
    }
  end

  def get_test_object(&twiddle_mocks)
    @mocks = test_mocks
    yield unless twiddle_mocks.nil?
    Quality::Rake::Task.new(@mocks)
  end
end
