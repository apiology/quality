# frozen_string_literal: true

require_relative 'test_helper'

# Test the LinguistSourceFileGlobber class
class TestLinguistSourceFileGlobber < MiniTest::Test
  let_mock :target, :blob_a_rb, :blob_b_md

  def expect_breakdown_pulled
    @mocks[:project]
      .expects(:breakdown_by_file)
      .returns('Ruby' => ['a.rb'])
  end

  def expect_file_blob_created(path, my_mock)
    @mocks[:file_blob]
      .expects(:new)
      .with(path, @mocks[:pwd])
      .returns(my_mock)
  end

  def expect_real_file(path)
    @mocks[:file_class].expects(:exist?).with(path).returns(true)
    @mocks[:file_class].expects(:symlink?).with(path).returns(false)
    @mocks[:file_class].expects(:readable?).with(path).returns(true)
  end

  def mock_ruby_file_found
    expect_file_blob_created('a.rb', blob_a_rb)
    expect_real_file('a.rb')
    blob_a_rb.expects(:generated?).returns(false)
    blob_a_rb.expects(:vendored?).returns(false)
    blob_a_rb.expects(:documentation?).returns(false).at_least(0)
    blob_a_rb.expects(:language).returns('Ruby').at_least(0)
  end

  def mock_markdown_file_found
    expect_file_blob_created('foo/b.md', blob_b_md)
    expect_real_file('foo/b.md')
    blob_b_md.expects(:generated?).returns(false)
    blob_b_md.expects(:vendored?).returns(false)
    blob_b_md.expects(:documentation?).returns(true).at_least(0)
    blob_b_md.expects(:language).returns(nil).at_least(0)
  end

  let_mock :tree

  def mock_files_found
    expect_breakdown_pulled
    @mocks[:commit].expects(:target).returns(target).at_least(0)
    target.expects(:tree).returns(tree)
    tree
      .expects(:walk).with(:preorder)
      .multiple_yields(['', type: :blob, name: 'a.rb'],
                       ['', type: :tree, name: 'foo'],
                       ['foo/', type: :blob, name: 'b.md'])

    mock_ruby_file_found

    mock_markdown_file_found
  end

  def test_source_and_doc_files
    globber = get_test_object do
      mock_files_found
    end
    assert_equal(['a.rb', 'foo/b.md'], globber.source_and_doc_files)
  end

  def test_source_files
    globber = get_test_object do
      mock_files_found
    end
    assert_equal(['a.rb'], globber.source_files)
  end

  def test_ruby_files
    globber = get_test_object do
      expect_breakdown_pulled
    end
    assert_equal(['a.rb'], globber.ruby_files)
  end

  def get_test_object(&twiddle_mocks)
    @mocks = get_initializer_mocks(Quality::LinguistSourceFileGlobber)
    yield @mocks unless twiddle_mocks.nil?
    Quality::LinguistSourceFileGlobber.new(@mocks)
  end
end
