require_relative 'base_test_task.rb'

class TestTaskRatchet < BaseTestTask
  def test_ratchet_task
    get_test_object { setup_ratchet_task_mocks }
  end

  def setup_ratchet_task_mocks
    expect_tools_tasks_defined(ALL_TOOLS)
    expect_define_task.with('quality')
    expect_define_task.with('ratchet').yields
    expect_glob.with('metrics/*_high_water_mark')
      .returns(%w(metrics/foo_high_water_mark
                  metrics/bar_high_water_mark))
    expect_ratchet('foo', 12)
    expect_ratchet('bar', 96)
  end

  def expect_ratchet(tool_name, old_high_water_mark)
    filename = "metrics/#{tool_name}_high_water_mark"
    expect_read_from_high_water_mark(filename, old_high_water_mark)
    expect_write_to_high_water_mark(filename, old_high_water_mark - 1)
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
end
