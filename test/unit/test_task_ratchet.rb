# frozen_string_literal: true
require_relative 'test_helper'
require_relative 'base_test_task.rb'

# Test the process of finding fewer problems and tweaking down the
# numbers
class TestTaskRatchet < BaseTestTask
  def test_ratchet_task
    get_test_object { setup_ratchet_task_mocks }
  end

  def setup_ratchet_task_mocks
    expect_config_pulled
    expect_tools_tasks_defined(ALL_TOOLS)
    expect_define_task.with(quality_name)
    expect_define_task.with(ratchet_name)
  end
end
