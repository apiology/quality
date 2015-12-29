#!/usr/bin/env ruby

require_relative 'test_helper.rb'
require_relative 'tools/cane'
require_relative 'tools/flay'
require_relative 'tools/flog'
require_relative 'tools/reek'
require_relative 'tools/rubocop'
require_relative 'tools/bigfiles'
require_relative 'tools/punchlist'
require_relative 'tools/brakeman'
require_relative 'tools/rails_best_practices'
require_relative 'tools/eslint'
require_relative 'tools/jscs'
require_relative 'tools/pep8'

# Unit test the Task class
class TestTask < MiniTest::Test
  include ::Test::Quality::Tools::Cane
  include ::Test::Quality::Tools::Eslint
  include ::Test::Quality::Tools::Jscs
  include ::Test::Quality::Tools::Flay
  include ::Test::Quality::Tools::Flog
  include ::Test::Quality::Tools::Reek
  include ::Test::Quality::Tools::Rubocop
  include ::Test::Quality::Tools::BigFiles
  include ::Test::Quality::Tools::Punchlist
  include ::Test::Quality::Tools::Brakeman
  include ::Test::Quality::Tools::RailsBestPractices
  include ::Test::Quality::Tools::Pep8

  def test_quality_task_all_tools
    get_test_object do |_task|
      setup_quality_task_mocks
    end
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

  def expect_tools_tasks_defined(tools)
    tools.each { |tool| expect_define_task.with(tool) }
  end

  ALL_TOOLS = %w(cane flog flay reek rubocop bigfiles punchlist brakeman
                 rails_best_practices eslint jscs pep8)

  def expect_tools_run(tools)
    tools.each { |tool_name| expect_single_tool_run(tool_name) }
  end

  def expect_tools_installed(tools)
    tools.each do |tool_name|
      expect_gemspec_tool_found(tool_name, true)
    end
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

  def test_ratchet_task
    get_test_object do
      setup_ratchet_task_mocks
    end
  end

  def expect_define_task
    @mocks[:dsl].expects(:define_task)
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
    'html,java,js,json,md,py,rake,rb,scala,sh,swift,' \
    'yml},{app,config,db,feature,lib,' \
    'spec,src,test,www}/**/{*,.*}.' \
    '{c,clj,cljs,cpp,gemspec,' \
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
      '{src}/**/{*,.*}.{py}}'
    expect_glob.with(source_glob)
      .returns(['fake1.py'])
  end

  def expect_glob
    @mocks[:globber].expects(:glob)
  end

  def get_test_object(fiddle_with_task = ->(_task) {}, &twiddle_mocks)
    @mocks = get_initializer_mocks(Quality::Rake::Task)
    yield @mocks unless twiddle_mocks.nil?
    Quality::Rake::Task.new(@mocks) { |task| fiddle_with_task.call(task) }
  end
end
