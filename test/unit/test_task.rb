#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'test_helper.rb'
require_relative 'base_test_task.rb'

# Unit test the Task class
class TestTask < BaseTestTask
  def test_quality_task_all_tools
    get_test_object { |_task| setup_quality_task_mocks }
  end

  def test_quality_task_some_suppressed
    get_test_object(->(task) { task.skip_tools = ['flog'] }) do
      setup_quality_task_mocks(suppressed_tools: ['flog'])
    end
  end

  def expect_cane_not_found
    @mocks[:which].expects(:which).with('cane').returns(nil)
  end

  def test_quality_task_some_not_installed
    get_test_object do |_task|
      setup_quality_task_mocks(uninstalled_tools: ['cane'])
      expect_cane_not_found
    end
  end

  def expect_skip_tools_pulled(suppressed_tools)
    @mocks[:config]
      .expects(:skip_tools).returns(suppressed_tools)
      .at_least(1)
  end

  def expect_output_dir_pulled
    @mocks[:config]
      .expects(:output_dir).returns('metrics')
      .at_least(1)
  end

  def expect_verbose_false
    @mocks[:config]
      .expects(:verbose).returns(false)
      .at_least(1)
  end

  def expect_skip_tools_assigned(suppressed_tools)
    return if suppressed_tools.empty?

    @mocks[:config].expects(:skip_tools=).with(suppressed_tools)
  end

  def expect_minimum_threshold_pulled
    @mocks[:config].expects(:minimum_threshold)
                   .returns(bigfiles: 300).at_least(1)
  end

  def expect_tools_configured(suppressed_tools, uninstalled_tools)
    expect_tools_installed(ALL_TOOLS - uninstalled_tools)
    expect_skip_tools_assigned(suppressed_tools)
    expect_skip_tools_pulled(suppressed_tools)
    expect_minimum_threshold_pulled
  end

  def setup_quality_task_mocks(suppressed_tools: [], uninstalled_tools: [])
    expect_task_names_pulled
    expect_tools_tasks_defined(ALL_TOOLS)
    expect_define_task.with(quality_name).yields
    expect_define_task.with(ratchet_name)
    expect_tools_configured(suppressed_tools, uninstalled_tools)
    expect_output_dir_pulled
    expect_verbose_false
    tools_that_actually_run = (ALL_TOOLS - suppressed_tools) - uninstalled_tools
    expect_tools_run(tools_that_actually_run)
  end

  def expect_tools_run(tools)
    tools.each { |tool_name| expect_single_tool_run(tool_name) }
  end

  def expect_tools_installed(tools)
    tools.each { |tool_name| expect_gemspec_tool_found(tool_name, true) }
    (ALL_TOOLS - tools).each do |tool_name|
      expect_gemspec_tool_found(tool_name, false)
    end
  end

  def expect_single_tool_run(tool_name)
    quality_checker = mock('quality_checker')
    method("expect_#{tool_name}_run").call(quality_checker)
    file = self.class.sample_output(tool_name)
    lines = file.lines.map(&:strip)
    quality_checker.expects(:execute).multiple_yields(*lines)
  end

  def expect_gemspec_tool_found(tool_name, was_found)
    @mocks[:gem_spec].expects(:find_all_by_name)
                     .with(tool_name).returns([was_found])
  end

  def self.sample_output(tool_name)
    IO.read("#{File.dirname(__FILE__)}/samples/#{tool_name}_sample_output")
  end

  def expected_ruby_source_glob
    '{fake1.rb,fake2.rb,features/featuresfake1.rb,' \
    'lib/libfake1.rb,test/testfake1.rb}'
  end

  def expect_find_ruby_files
    ruby_files =
      %w(fake1.rb fake2.rb features/featuresfake1.rb lib/libfake1.rb
         test/testfake1.rb)
    @mocks[:config].expects(:ruby_files).returns(ruby_files)
  end

  def expect_find_shell_files
    shell_files = %w(fake1.sh)
    @mocks[:config].expects(:shell_files).returns(shell_files)
  end

  def expected_source_and_doc_files_glob
    '{fake1.py,README.md}'
  end

  def expect_find_js_files
    @mocks[:config]
      .expects(:js_files)
      .returns(%w(fake1.js features/featuresfake1.js src/foo/testfake1.js))
  end

  def expect_find_python_files
    @mocks[:config].expects(:python_files).returns(['fake1.py'])
  end

  def expect_find_markdown_files
    @mocks[:config]
      .expects(:markdown_files)
      .returns(['file1.md', 'file2.md'])
      .at_least(1)
  end

  def expect_find_scala_files
    @mocks[:config]
      .expects(:scala_files)
      .returns(['s1.scala', 's2.scala'])
      .at_least(1)
  end

  def expect_find_source_files
    @mocks[:config]
      .expects(:source_files).returns(['fake1.py', 'README.md'])
      .at_least(0)
    @mocks[:config]
      .expects(:source_files_glob)
      .returns('{fake1.py,README.md}')
      .at_least(0)
  end

  def expect_find_exclude_files
    @mocks[:config]
      .expects(:exclude_files)
      .returns(['fake1.py'])
      .at_least(0)
  end

  def expect_find_exclude_glob
    @mocks[:config]
      .expects(:source_files_exclude_glob)
      .returns('{**/vendor/**,db/schema.rb}')
      .at_least(1)
  end
end
