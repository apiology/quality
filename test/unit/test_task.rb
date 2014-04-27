# Unit test the Task class
class TestTask < Test::Unit::TestCase
  def test_quality_task
    task = get_test_object do
      setup_quality_task_mocks
    end
  end

  def setup_quality_task_mocks
    expect_define_task.with('quality').yields
    expect_define_task.with('ratchet')
    expect_tools_run
  end

  def expect_define_task
    @mocks[:dsl].expects(:define_task)
  end

  def expect_tools_run
    %w{ cane flog flay reek rubocop }.each do |tool_name|
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
    expect_define_task.with('quality')
    expect_define_task.with('ratchet').yields
    @mocks[:globber].expects(:glob)
      .with('./*_high_water_mark').returns(%w{./foo_high_water_mark
                                              ./bar_high_water_mark})
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
    file.expects(:write).with(new_high_water_mark.to_s)
  end

  def expect_cane_run(quality_checker)
    @mocks[:quality_checker_class]
      .expects(:new).with('cane',
                          { gives_error_code_on_violations: true,
                            emacs_format: true },
                          '.')
      .returns(quality_checker)
    @mocks[:configuration_writer].expects(:exist?).with('.cane').returns(true)
    expect_installed('cane')
  end

  def expect_installed(tool_name)
    @mocks[:gem_spec].expects(:find_all_by_name)
      .with(tool_name).returns([true])
  end

  def expect_flog_run(quality_checker)
    @mocks[:quality_checker_class]
      .expects(:new).with('flog',
                          { args: self.class.flog_args,
                            emacs_format: true },
                          '.')
      .returns(quality_checker)
    expect_find_ruby_files
    expect_installed('flog')
  end

  def self.flog_args
    '--all --continue --methods-only ' +
      'fake1.rb fake2.rb lib/libfake1.rb ' +
      'test/testfake1.rb features/featuresfake1.rb'
  end

  def expect_flay_run(quality_checker)
    @mocks[:quality_checker_class]
      .expects(:new).with('flay',
                          { args: self.class.flay_args,
                            emacs_format: true },
                          '.')
      .returns(quality_checker)
    expect_find_ruby_files
    expect_installed('flay')
  end

  def self.flay_args
    '-m 75 -t 99999 ' +
      'fake1.rb fake2.rb lib/libfake1.rb ' +
      'test/testfake1.rb features/featuresfake1.rb'
  end

  def expect_reek_run(quality_checker)
    @mocks[:quality_checker_class]
      .expects(:new).with('reek',
                          { args: self.class.reek_args,
                            emacs_format: true,
                            gives_error_code_on_violations: true },
                          '.')
      .returns(quality_checker)
    expect_find_ruby_files
    expect_installed('reek')
  end

  def self.reek_args
    '--single-line fake1.rb fake2.rb ' +
      'lib/libfake1.rb test/testfake1.rb features/featuresfake1.rb'
  end

  def expect_rubocop_run(quality_checker)
    @mocks[:quality_checker_class]
      .expects(:new).with('rubocop',
                          { args: self.class.rubocop_args,
                            gives_error_code_on_violations: true },
                          '.')
      .returns(quality_checker)
    expect_find_ruby_files
    expect_installed('rubocop')
  end

  def self.rubocop_args
    '--format emacs fake1.rb fake2.rb lib/libfake1.rb ' +
      'test/testfake1.rb features/featuresfake1.rb'
  end

  def self.sample_output(tool_name)
    IO.read("#{File.dirname(__FILE__)}/samples/#{tool_name}_sample_output")
  end

  def expect_find_ruby_files
    expect_glob.with('*.rb').returns(['fake1.rb', 'fake2.rb'])
    expect_glob.with('{lib,test,features}/**/*.rb')
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
