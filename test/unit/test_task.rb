#!/usr/bin/env ruby

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

  def test_quality_task_some_not_installed
    get_test_object do |_task|
      setup_quality_task_mocks(uninstalled_tools: ['cane'])
      @mocks[:which].expects(:which).with('cane').returns(nil)
    end
  end

  def setup_quality_task_mocks(suppressed_tools: [], uninstalled_tools: [])
    expect_tools_tasks_defined(ALL_TOOLS)
    expect_define_task.with('quality').yields
    expect_define_task.with('ratchet')
    expect_tools_installed(ALL_TOOLS - uninstalled_tools)
    tools_that_actually_run = (ALL_TOOLS - suppressed_tools) - uninstalled_tools
    expect_tools_run(tools_that_actually_run)
    expect_find_exclude_files
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
    '{Rakefile,{*,.*}.{gemspec,rake,rb},' \
    '{app,config,db,feature,lib,spec,src,test}/**/{*,.*}.{gemspec,rake,rb}}'
  end

  def expect_find_ruby_files
    expect_glob.with(expected_ruby_source_glob)
      .returns(['fake1.rb', 'fake2.rb', 'lib/libfake1.rb',
                'test/testfake1.rb',
                'features/featuresfake1.rb',
                'db/schema.rb'])
  end

  def expect_find_exclude_files
    expect_glob.with('{**/vendor/**,db/schema.rb}')
      .returns(['vendor/fake1.rb', 'vendor/fake1.js', 'db/schema.rb',
                'src/js/vendor/vendor_file.js'])
      .at_least(1)
  end

  def expected_source_and_doc_files_glob
    '{Dockerfile,Rakefile,{*,.*}.{c,clj,cljs,cpp,gemspec,' \
    'groovy,html,java,js,json,md,py,rake,rb,scala,sh,swift,' \
    'yml},{app,config,db,feature,lib,' \
    'spec,src,test,tests,var,www}/**/{*,.*}.' \
    '{c,clj,cljs,cpp,gemspec,groovy,' \
    'html,java,js,json,md,py,rake,rb,scala,sh,swift,yml}}'
  end

  def expect_find_js_files
    source_glob =
      '{{*,.*}.{js},' \
      '{app,src,www}/**/{*,.*}.{js}}'
    expect_glob.with(source_glob)
      .returns(['fake1.js',
                'src/js/vendor/vendor_file.js',
                'src/foo/testfake1.js',
                'features/featuresfake1.js',
                'vendor/fake1.js'])
  end

  def expect_find_python_files
    source_glob =
      '{{*,.*}.{py},' \
      '{src,tests}/**/{*,.*}.{py}}'
    expect_glob.with(source_glob)
      .returns(['fake1.py'])
  end
end
