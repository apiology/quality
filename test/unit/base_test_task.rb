# frozen_string_literal: true

require 'quality/directory_of_classes'

# Tests that run individual tools as part of the test
class BaseTestTask < MiniTest::Test
  current_dir = File.dirname(File.expand_path(__FILE__))
  tool_classes = DirectoryOfClasses.new(dir: "#{current_dir}/tools",
                                        module_name: 'Test::Quality::Tools')
  ALL_TOOLS = tool_classes.basenames_without_extension
  tool_classes.require_classes
  tool_classes.symbols_and_classes.each { |_symbol, clazz| include clazz }

  def get_test_object(fiddle_with_task = ->(_task) {}, &twiddle_mocks)
    @mocks = get_initializer_mocks(Quality::Rake::Task)
    yield @mocks unless twiddle_mocks.nil?
    Quality::Rake::Task.new(**@mocks) { |task| fiddle_with_task.call(task) }
  end

  def expect_tools_tasks_defined(tools)
    tools.each { |tool| expect_define_task.with(tool) }
  end

  def expect_define_task
    @mocks[:dsl].expects(:define_task)
  end

  let_mock :quality_name, :ratchet_name

  def expect_config_pulled
    expect_task_names_pulled
    @mocks[:config]
      .expects(:skip_tools).returns([])
      .at_least(0)
  end

  def expect_task_names_pulled
    @mocks[:config].expects(:quality_name).returns(quality_name)
    @mocks[:config].expects(:ratchet_name).returns(ratchet_name)
  end
end
