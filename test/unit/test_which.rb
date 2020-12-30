# frozen_string_literal: true

require_relative 'test_helper'

# Test the Which class
class TestWhich < MiniTest::Test
  let_mock :cmd, :pathext, :dirname,
           :foo_potential_bin_path,
           :bar_potential_bin_path,
           :baz_potential_bin_path

  def expect_path_queried(dirname, binpath, executable, directory,
                          extension = '')
    @mocks[:file].expects(:join).with(dirname, "#{cmd}#{extension}")
                 .returns(binpath)
    @mocks[:file].expects(:executable?).with(binpath)
                 .returns(executable)
    @mocks[:file].expects(:directory?).with(binpath)
                 .returns(directory)
                 .at_least(0)
  end

  def mock_unix
    @mocks[:env] = {
      'PATH' => 'foo:bar:baz',
    }
    [
      ['foo', foo_potential_bin_path, true, true],
      ['bar', bar_potential_bin_path, false, nil],
      ['baz', baz_potential_bin_path, true, false],
    ].each do |dirname, binpath, executable, directory|
      expect_path_queried(dirname, binpath, executable, directory)
    end
  end

  def mock_windows
    @mocks[:env] = {
      'PATHEXT' => '.COM;.EXE;.BAT',
      'PATH' => 'foo;bar;baz',
    }
    expect_path_queried('foo', foo_potential_bin_path, true, false, '.COM')
  end

  def test_which_unix
    which = get_test_object(':') do
      mock_unix
    end
    assert_equal(baz_potential_bin_path, which.which(cmd))
  end

  def test_which_windows
    which = get_test_object(';') do
      mock_windows
    end
    assert_equal(foo_potential_bin_path, which.which(cmd))
  end

  def create_mocks(separator)
    {
      env: mock('env'),
      file: mock('file'),
      separator: separator,
    }
  end

  def get_test_object(separator, &twiddle_mocks)
    @mocks = create_mocks(separator)
    yield unless twiddle_mocks.nil?
    Quality::Which.new(**@mocks)
  end
end
