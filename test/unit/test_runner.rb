# frozen_string_literal: true

require_relative 'test_helper'

# Test the CommandOutputProcessor class
class TestRunner < MiniTest::Test
  def all_output_files
    %w[file1 file2]
  end

  def expect_filename_ratcheted(mocks, filename)
    mocks[:count_io].expects(:read).with(filename).returns('123')
    file = mock("file for #{filename}")
    mocks[:count_file].expects(:open).with(filename, 'w').yields(file)
    file.expects(:write).with("122\n")
  end

  def test_run_ratchet
    runner = get_test_object do |mocks|
      config.expects(:all_output_files).returns(all_output_files)
      all_output_files.each do |filename|
        expect_filename_ratcheted(mocks, filename)
      end
    end
    runner.run_ratchet
  end

  let_mock :config

  def get_test_object(&twiddle_mocks)
    mocks = get_initializer_mocks(Quality::Runner)
    yield mocks unless twiddle_mocks.nil?
    Quality::Runner.new(config, mocks)
  end
end
