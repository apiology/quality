# Test the ProcessRunner class
class TestProcess < MiniTest::Test
  def test_run
    cmd = mock('cmd')
    file = mock('file')
    process = get_test_object(cmd) do
      @mocks[:popener].expects(:popen).with(cmd).yields(file)
    end
    process.run do |file_yielded|
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
    Quality::Process.new(cmd, @mocks)
  end
end
