require_relative 'test_helper'

# Test the LinguistSourceFileGlobber class
class TestLinguistSourceFileGlobber < MiniTest::Test
  let_mock :target, :blob_a_rb, :blob_b_md

  def expect_breakdown_pulled(mocks)
    mocks[:project]
      .expects(:breakdown_by_file)
      .returns('Ruby' => ['a.rb'])
  end

  def mock_ruby_file_found(mocks)
    mocks[:file_blob]
      .expects(:new)
      .with('a.rb', mocks[:pwd])
      .returns(blob_a_rb)
    blob_a_rb.expects(:generated?).returns(false)
    blob_a_rb.expects(:vendored?).returns(false)
    blob_a_rb.expects(:documentation?).returns(false).at_least(0)
    blob_a_rb.expects(:language).returns('Ruby').at_least(0)
  end

  def mock_markdown_file_found(mocks)
    mocks[:file_blob]
      .expects(:new)
      .with('b.md', mocks[:pwd])
      .returns(blob_b_md)
    blob_b_md.expects(:generated?).returns(false)
    blob_b_md.expects(:vendored?).returns(false)
    blob_b_md.expects(:documentation?).returns(true).at_least(0)
    blob_b_md.expects(:language).returns(nil).at_least(0)
  end

  def mock_files_found(mocks)
    expect_breakdown_pulled(mocks)
    mocks[:commit].expects(:target).returns(target).at_least(0)
    target.expects(:tree).returns([{ type: :blob, name: 'a.rb' },
                                   { type: :blob, name: 'b.md' }])

    mock_ruby_file_found(mocks)

    mock_markdown_file_found(mocks)
  end

  def test_source_and_doc_files
    globber = get_test_object do |mocks|
      mock_files_found(mocks)
    end
    assert_equal(['a.rb', 'b.md'], globber.source_and_doc_files)
  end

  def test_source_files
    globber = get_test_object do |mocks|
      mock_files_found(mocks)
    end
    assert_equal(['a.rb'], globber.source_files)
  end

  def test_ruby_files
    globber = get_test_object do |mocks|
      expect_breakdown_pulled(mocks)
    end
    assert_equal(['a.rb'], globber.ruby_files)
  end

  def get_test_object(&twiddle_mocks)
    mocks = get_initializer_mocks(Quality::LinguistSourceFileGlobber)
    yield mocks unless twiddle_mocks.nil?
    Quality::LinguistSourceFileGlobber.new(mocks)
  end
end
