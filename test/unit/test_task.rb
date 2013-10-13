# Unit test the Task class
class TestTask < Test::Unit::TestCase
  def test_quality_task
    task = get_test_object do |mocks|
      mocks[:dsl].expects(:task).with('quality').yields
      expect_cane_run(mocks)
      expect_flog_run(mocks)
      expect_flay_run(mocks)
      expect_reek_run(mocks)
      expect_rubocop_run(mocks)
      mocks[:dsl].expects(:task).with('ratchet')
    end
  end

  def expect_cane_run(mocks)
    mocks[:configuration_writer].expects(:exist?).with('.cane').returns(true)
    cane_file = StringIO.new(cane_output)
    mocks[:popener].expects(:popen).with('cane').yields(cane_file)
    mock_high_water_mark(mocks, 'cane', 555)
    expect_write_new_high_water_mark(mocks, 'cane', 11)
  end

  def expect_flog_run(mocks)
    expect_find_ruby_files(mocks)
    flog_file = StringIO.new(flog_output)
    flog_cmd =
      'flog --all --continue --methods-only ' +
      'fake1.rb fake2.rb lib/libfake1.rb test/testfake1.rb features/featuresfake1.rb'
    mocks[:popener].expects(:popen)
      .with(flog_cmd)
      .yields(flog_file)
    mock_high_water_mark(mocks, 'flog', 555)
    expect_write_new_high_water_mark(mocks, 'flog', 0)
  end

  def expect_flay_run(mocks)
    expect_find_ruby_files(mocks)
    flay_file = StringIO.new(flay_output)
    flay_cmd =
      'flay -m 75 -t 99999 ' +
      'fake1.rb fake2.rb lib/libfake1.rb test/testfake1.rb features/featuresfake1.rb'
    mocks[:popener].expects(:popen).with(flay_cmd)
      .yields(flay_file)
    mock_high_water_mark(mocks, 'flay', 555)
    expect_write_new_high_water_mark(mocks, 'flay', 0)
  end

  def expect_reek_run(mocks)
    expect_find_ruby_files(mocks)
    reek_file = StringIO.new(reek_output)
    reek_cmd =
      'reek --line-number fake1.rb fake2.rb ' +
      'lib/libfake1.rb test/testfake1.rb features/featuresfake1.rb'
    mocks[:popener].expects(:popen).with(reek_cmd)
      .yields(reek_file)
    mock_high_water_mark(mocks, 'reek', 555)
    expect_write_new_high_water_mark(mocks, 'reek', 22)
  end

  def expect_rubocop_run(mocks)
    expect_find_ruby_files(mocks)
    rubocop_file = StringIO.new(rubocop_output)
    mocks[:popener].expects(:popen).with('rubocop --format emacs fake1.rb fake2.rb lib/libfake1.rb test/testfake1.rb features/featuresfake1.rb')
      .yields(rubocop_file)
    mock_high_water_mark(mocks, 'rubocop', 555)
    expect_write_new_high_water_mark(mocks, 'rubocop', 35)
  end

  def rubocop_output
    output = <<END
/Users/broz/src/quality/lib/quality/version.rb:1:1: C: Missing top-level module documentation comment.
/Users/broz/src/quality/test/unit/test_task.rb:4:5: W: Useless assignment to variable - task
/Users/broz/src/quality/test/unit/test_task.rb:24:80: C: Line is too long. [158/79]
/Users/broz/src/quality/test/unit/test_task.rb:33:80: C: Line is too long. [141/79]
/Users/broz/src/quality/test/unit/test_task.rb:36:55: C: Trailing whitespace detected.
/Users/broz/src/quality/test/unit/test_task.rb:42:80: C: Line is too long. [140/79]
/Users/broz/src/quality/test/unit/test_task.rb:45:56: C: Trailing whitespace detected.
/Users/broz/src/quality/test/unit/test_task.rb:48:3: C: Method has too many lines. [27/10]
/Users/broz/src/quality/test/unit/test_task.rb:49:5: W: Useless assignment to variable - output
/Users/broz/src/quality/test/unit/test_task.rb:51:80: C: Line is too long. [88/79]
/Users/broz/src/quality/test/unit/test_task.rb:53:80: C: Line is too long. [86/79]
/Users/broz/src/quality/test/unit/test_task.rb:55:80: C: Line is too long. [91/79]
/Users/broz/src/quality/test/unit/test_task.rb:56:80: C: Line is too long. [96/79]
/Users/broz/src/quality/test/unit/test_task.rb:57:80: C: Line is too long. [84/79]
/Users/broz/src/quality/test/unit/test_task.rb:58:80: C: Line is too long. [100/79]
/Users/broz/src/quality/test/unit/test_task.rb:59:80: C: Line is too long. [92/79]
/Users/broz/src/quality/test/unit/test_task.rb:60:80: C: Line is too long. [108/79]
/Users/broz/src/quality/test/unit/test_task.rb:61:80: C: Line is too long. [80/79]
/Users/broz/src/quality/test/unit/test_task.rb:62:80: C: Line is too long. [80/79]
/Users/broz/src/quality/test/unit/test_task.rb:65:80: C: Line is too long. [92/79]
/Users/broz/src/quality/test/unit/test_task.rb:66:80: C: Line is too long. [107/79]
/Users/broz/src/quality/test/unit/test_task.rb:67:80: C: Line is too long. [89/79]
/Users/broz/src/quality/test/unit/test_task.rb:68:80: C: Line is too long. [83/79]
/Users/broz/src/quality/test/unit/test_task.rb:70:80: C: Line is too long. [91/79]
/Users/broz/src/quality/test/unit/test_task.rb:71:80: C: Line is too long. [87/79]
/Users/broz/src/quality/test/unit/test_task.rb:72:80: C: Line is too long. [81/79]
/Users/broz/src/quality/test/unit/test_task.rb:79:5: W: Useless assignment to variable - output
/Users/broz/src/quality/test/unit/test_task.rb:79:12: C: Surrounding space missing for operator '='.
/Users/broz/src/quality/test/unit/test_task.rb:84:1: C: Trailing whitespace detected.
/Users/broz/src/quality/test/unit/test_task.rb:86:80: C: Line is too long. [81/79]
/Users/broz/src/quality/test/unit/test_task.rb:88:80: C: Line is too long. [85/79]
/Users/broz/src/quality/test/unit/test_task.rb:107:5: W: Useless assignment to variable - output
/Users/broz/src/quality/test/unit/test_task.rb:118:1: C: Trailing whitespace detected.
/Users/broz/src/quality/test/unit/test_task.rb:119:3: C: Method has too many lines. [16/10]
/Users/broz/src/quality/test/unit/test_task.rb:120:5: W: Useless assignment to variable - output
END
  end

  def reek_output
    output = <<END
    lib/quality/rake/task.rb -- 12 warnings:
  [30]:Quality::Rake::Task has at least 16 instance variables (TooManyInstanceVariables)
  [75]:Quality::Rake::Task#initialize performs a nil-check. (NilCheck)
  [269]:Quality::Rake::Task#quality contains iterators nested 2 deep (NestedIterators)
  [261]:Quality::Rake::Task#quality has approx 7 statements (TooManyStatements)
  [269]:Quality::Rake::Task#quality has the variable name 'f' (UncommunicativeVariableName)
  [181]:Quality::Rake::Task#quality_cane has the variable name 'f' (UncommunicativeVariableName)
  [216]:Quality::Rake::Task#quality_flog has approx 6 statements (TooManyStatements)
  [147, 150]:Quality::Rake::Task#ratchet_quality_cmd calls (out << line) twice (DuplicateMethodCall)
  [116]:Quality::Rake::Task#ratchet_quality_cmd has approx 26 statements (TooManyStatements)
  [139, 175]:Quality::Rake::Task#ratchet_quality_cmd has the variable name 'f' (UncommunicativeVariableName)
  [135]:Quality::Rake::Task#ratchet_quality_cmd performs a nil-check. (NilCheck)
  [100]:Quality::Rake::Task#run_task has approx 7 statements (TooManyStatements)
test/unit/test_helper.rb -- 0 warnings
test/unit/test_task.rb -- 9 warnings:
  [46, 47]:TestTask#expect_find_ruby_files calls mocks[:globber] twice (DuplicateMethodCall)
  [46, 47]:TestTask#expect_find_ruby_files calls mocks[:globber].expects(:glob) twice (DuplicateMethodCall)
  [45]:TestTask#expect_find_ruby_files doesn't depend on instance state (UtilityFunction)
  [45]:TestTask#expect_find_ruby_files refers to mocks more than self (FeatureEnvy)
  [115]:TestTask#get_test_object performs a nil-check. (NilCheck)
  [60, 62]:TestTask#mock_high_water_mark calls mocks[:count_io] twice (DuplicateMethodCall)
  [59]:TestTask#mock_high_water_mark doesn't depend on instance state (UtilityFunction)
  [59]:TestTask#mock_high_water_mark refers to mocks more than self (FeatureEnvy)
  [3]:TestTask#test_task has approx 6 statements (TooManyStatements)
21 total warnings
END
  end

  def flay_output
    output =<<END
    Total score (lower is better) = 0
END
  end


  def expect_find_ruby_files(mocks)
    mocks[:globber].expects(:glob).with('*.rb').returns(['fake1.rb', 'fake2.rb'])
    mocks[:globber].expects(:glob).with('{lib,test,features}/**/*.rb')
      .returns(['lib/libfake1.rb', 'test/testfake1.rb', 'features/featuresfake1.rb'])
  end

  def expect_write_new_high_water_mark(mocks, tool_name, violations)
    high_water_mark_file = mock("#{tool_name}_high_water_mark_file")
    mocks[:count_file].expects(:open).with("./#{tool_name}_high_water_mark", 'w')
      .yields(high_water_mark_file)
    # number of violations in 'cane_output' below
    high_water_mark_file.expects(:write).with(violations.to_s)
  end

  def mock_high_water_mark(mocks, tool_name, num_violations)
    mocks[:count_file].expects(:exist?).with("./#{tool_name}_high_water_mark")
      .returns(true)
    mocks[:count_io].expects(:read).with("./#{tool_name}_high_water_mark")
      .returns(num_violations.to_s)
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
    mocks = test_mocks
    yield mocks unless twiddle_mocks.nil?
    Quality::Rake::Task.new(mocks)
  end
end
