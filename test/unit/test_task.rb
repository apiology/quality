# Unit test the Task class
class TestTask < Test::Unit::TestCase
  def test_quality_task
    task = get_test_object do
      setup_quality_task_mocks
    end
  end

  def setup_quality_task_mocks
    dsl_mock = @mocks[:dsl]
    dsl_mock.expects(:define_task).with('quality').yields
    expect_tools_run
    expect_rubocop_run
    dsl_mock.expects(:define_task).with('ratchet')
  end

  def expect_tools_run
    expect_cane_run
    expect_flog_run
    expect_flay_run
    expect_reek_run
  end

  def test_ratchet_task
    task = get_test_object do
      setup_ratchet_task_mocks
    end
  end

  def setup_ratchet_task_mocks
    @mocks[:dsl].expects(:define_task).with('quality')
    @mocks[:dsl].expects(:define_task).with('ratchet').yields
    @mocks[:globber].expects(:glob)
      .with('*_high_water_mark').returns(%w{foo_high_water_mark
                                            bar_high_water_mark})
    expect_ratchet('foo', 12)
    expect_ratchet('bar', 96)
  end

  def expect_ratchet(tool_name, old_high_water_mark)
    filename = "#{tool_name}_high_water_mark"
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
    file.expects(:write).with((new_high_water_mark).to_s)
  end

  def expect_cane_run
    @mocks[:configuration_writer].expects(:exist?).with('.cane').returns(true)
    cane_file = StringIO.new(cane_output)
    @mocks[:popener].expects(:popen).with('cane').yields(cane_file)
    mock_high_water_mark('cane', 555)
    expect_write_new_high_water_mark('cane', 11)
  end

  def flog_cmd
    'flog --all --continue --methods-only ' +
      'fake1.rb fake2.rb lib/libfake1.rb ' +
      'test/testfake1.rb features/featuresfake1.rb'
  end

  def expect_flog_run
    expect_find_ruby_files(@mocks[:globber])
    flog_file = StringIO.new(flog_output)
    @mocks[:popener].expects(:popen)
      .with(flog_cmd)
      .yields(flog_file)
    mock_high_water_mark('flog', 555)
    expect_write_new_high_water_mark('flog', 0)
  end

  def expect_flay_run
    expect_find_ruby_files(@mocks[:globber])
    flay_file = StringIO.new(flay_output)
    @mocks[:popener].expects(:popen).with(self.class.flay_cmd)
      .yields(flay_file)
    mock_high_water_mark('flay', 555)
    expect_write_new_high_water_mark('flay', 0)
  end

  def self.flay_cmd
    'flay -m 75 -t 99999 ' +
      'fake1.rb fake2.rb lib/libfake1.rb ' +
      'test/testfake1.rb features/featuresfake1.rb'
  end

  def self.reek_cmd
    'reek --single-line fake1.rb fake2.rb ' +
      'lib/libfake1.rb test/testfake1.rb features/featuresfake1.rb'
  end

  def expect_reek_run
    expect_find_ruby_files(@mocks[:globber])
    reek_file = StringIO.new(reek_output)
    @mocks[:popener].expects(:popen).with(self.class.reek_cmd)
      .yields(reek_file)
    mock_high_water_mark('reek', 555)
    expect_write_new_high_water_mark('reek', 22)
  end

  def self.rubocop_cmd
    'rubocop --format emacs fake1.rb fake2.rb lib/libfake1.rb ' +
      'test/testfake1.rb features/featuresfake1.rb'
  end

  def expect_rubocop_run
    expect_find_ruby_files(@mocks[:globber])
    rubocop_file = StringIO.new(rubocop_output)
    @mocks[:popener].expects(:popen).with(self.class.rubocop_cmd)
      .yields(rubocop_file)
    mock_high_water_mark('rubocop', 555)
    expect_write_new_high_water_mark('rubocop', 35)
  end

  def self.sample_output(tool_name)
    IO.read("#{File.dirname(__FILE__)}/samples/#{tool_name}_sample_output")
  end

  def rubocop_output
    self.class.sample_output('rubocop')
  end

  def reek_output
    self.class.sample_output('reek')
  end

  def flay_output
    output =<<END
    Total score (lower is better) = 0
END
  end

  def expect_find_ruby_files(globber_mock)
    globber_mock.expects(:glob).with('*.rb').returns(['fake1.rb', 'fake2.rb'])
    globber_mock.expects(:glob).with('{lib,test,features}/**/*.rb')
      .returns(['lib/libfake1.rb',
                'test/testfake1.rb',
                'features/featuresfake1.rb'])
  end

  def expect_write_new_high_water_mark(tool_name, violations)
    high_water_mark_file = mock("#{tool_name}_high_water_mark_file")
    @mocks[:count_file].expects(:open)
      .with("./#{tool_name}_high_water_mark", 'w')
      .yields(high_water_mark_file)
    # number of violations in 'cane_output' below
    high_water_mark_file.expects(:write).with(violations.to_s)
  end

  def mock_high_water_mark(tool_name, num_violations)
    filename = "./#{tool_name}_high_water_mark"
    @mocks[:count_file].expects(:exist?).with(filename)
      .returns(true)
    expect_read_from_high_water_mark(filename, num_violations)
  end

  def flog_output
    output = <<END
    72.3: flog total
    14.5: flog/method average

    49.3: TestTask#test_task               test/unit/test_task.rb:3
    11.6: TestTask#mock_high_water_mark    test/unit/test_task.rb:24
     6.0: TestTask#test_mocks              test/unit/test_task.rb:54
     4.3: TestTask#get_test_object         test/unit/test_task.rb:65
     1.0: TestTask#cane_output             test/unit/test_task.rb:31
END
  end

  def cane_output
    output = <<END
Methods exceeded maximum allowed ABC complexity (2):

  lib/quality/rake/task.rb  Quality::Rake::Task#ratchet_quality_cmd  24
  lib/quality/rake/task.rb  Quality::Rake::Task#initialize           16

Lines violated style requirements (9):

  lib/quality/rake/task.rb:43   Line is >80 characters (126)
  lib/quality/rake/task.rb:51   Line contains trailing whitespace
  lib/quality/rake/task.rb:65   Line contains trailing whitespace
  lib/quality/rake/task.rb:111  Line is >80 characters (83)
  lib/quality/rake/task.rb:150  Line is >80 characters (105)
  lib/quality/rake/task.rb:163  Line is >80 characters (90)
  lib/quality/rake/task.rb:190  Line is >80 characters (104)
  lib/quality/rake/task.rb:210  Line is >80 characters (82)
  lib/quality/rake/task.rb:261  Line is >80 characters (84)

Total Violations: 11
END
  end

  def test_mocks
    {
      dsl: mock('dsl'),
      cmd_runner: mock('cmd_runner'),
      popener: mock('popener'),
      globber: mock('globber'),
      count_io: mock('count_io'),
      count_file: mock('count_file'),
      configuration_writer: mock('configuration_writer'),
    }
  end

  def get_test_object(&twiddle_mocks)
    @mocks = test_mocks
    yield unless twiddle_mocks.nil?
    Quality::Rake::Task.new(@mocks)
  end
end
