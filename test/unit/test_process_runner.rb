# Test the ProcessRunner class
class TestProcessRunner < MiniTest::Unit::TestCase
  def test_run
    cmd = mock('cmd')
    file = mock('file')
    process_runner = get_test_object(cmd) do
      @mocks[:popener].expects(:popen).with(cmd).yields(file)
    end
    process_runner.run do |file_yielded|
      assert_equal(file, file_yielded)
    end
  end

  def test_mocks
    {
      popener: mock('popener'),
    }
  end

  def get_test_object(cmd, &twiddle_mocks)
    @mocks = test_mocks
    yield unless twiddle_mocks.nil?
    Quality::ProcessRunner.new(cmd, @mocks)
  end
end
