# frozen_string_literal: true

require_relative 'test_helper'

# Test the LinguistSourceFileGlobber class
class TestLinguistSourceFileGlobber < MiniTest::Test
  let_mock :target, :blob_a_rb, :blob_b_md, :blob_c, :blob_d_jsx

  def expect_breakdown_pulled
    @mocks[:project]
      .expects(:breakdown_by_file)
      .returns(
        'Ruby' => ['a.rb'],
        'Shell' => ['c'],
        'JavaScript' => ['d.jsx'],
      )
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

  def mock_file_found(filename,
                      file_mock,
                      generated: false,
                      vendored: false,
                      documentation: false,
                      language: raise)
    expect_real_file(filename)
    expect_file_blob_created(filename, file_mock)
    file_mock.expects(:generated?).returns(generated)
    file_mock.expects(:vendored?).returns(vendored)
    file_mock.expects(:documentation?).returns(documentation).at_least(0)
    file_mock.expects(:language).returns(language).at_least(0)
  end

  def mock_ruby_file_found
    mock_file_found('a.rb', blob_a_rb,
                    language: 'Ruby')
  end

  def mock_js_file_found
    mock_file_found('d.jsx', blob_d_jsx,
                    language: 'JavaScript')
  end

  def mock_markdown_file_found
    mock_file_found('foo/b.md', blob_b_md,
                    documentation: true,
                    language: 'Markdown')
  end

  def mock_shell_file_found
    mock_file_found('c', blob_c, language: 'Shell')
  end

  let_mock :tree

  def tree_results
    [
      ['', type: :blob, name: 'a.rb'],
      ['', type: :tree, name: 'foo'],
      ['foo/', type: :blob, name: 'b.md'],
      ['', type: :blob, name: 'c'],
      ['', type: :blob, name: 'd.jsx'],
    ]
  end

  def expect_tree_pulled
    @mocks[:commit].expects(:target).returns(target).at_least(0)
    target.expects(:tree).returns(tree)
    tree
      .expects(:walk).with(:preorder)
      .multiple_yields(*tree_results)
  end

  def mock_files_found
    expect_breakdown_pulled

    expect_tree_pulled

    mock_ruby_file_found

    mock_markdown_file_found

    mock_shell_file_found

    mock_js_file_found
  end

  def test_source_and_doc_files
    globber = get_test_object do
      mock_files_found
    end
    assert_equal(['a.rb', 'foo/b.md', 'c', 'd.jsx'],
                 globber.source_and_doc_files)
  end

  def test_source_files
    globber = get_test_object do
      mock_files_found
    end
    assert_equal(['a.rb', 'c', 'd.jsx'], globber.source_files)
  end

  def test_ruby_files
    globber = get_test_object do
      expect_breakdown_pulled
    end
    assert_equal(['a.rb'], globber.ruby_files)
  end

  def test_shell_files
    globber = get_test_object do
      expect_breakdown_pulled
    end
    assert_equal(['c'], globber.shell_files)
  end

  def test_js_files
    globber = get_test_object do
      expect_breakdown_pulled
    end
    assert_equal(['d.jsx'], globber.js_files)
  end

  def test_markdown_files
    globber = get_test_object do
      mock_files_found
    end
    assert_equal(['foo/b.md'], globber.markdown_files)
  end

  def get_test_object(&twiddle_mocks)
    @mocks = get_initializer_mocks(Quality::LinguistSourceFileGlobber)
    yield @mocks unless twiddle_mocks.nil?
    Quality::LinguistSourceFileGlobber.new(@mocks)
  end
end
