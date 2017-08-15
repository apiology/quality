# frozen_string_literal: true

require_relative 'test_linguist_source_file_globber'

# Test the LinguistSourceFileGlobber class
class TestLinguistSourceFileGlobberSpecific < TestLinguistSourceFileGlobber
  def test_ruby_files
    globber = get_test_object { expect_breakdown_pulled }
    assert_equal(['a.rb'], globber.ruby_files)
  end

  def test_shell_files
    globber = get_test_object { expect_breakdown_pulled }
    assert_equal(['c'], globber.shell_files)
  end

  def test_js_files
    globber = get_test_object { expect_breakdown_pulled }
    assert_equal(['d.jsx'], globber.js_files)
  end

  def test_scala_files
    globber = get_test_object { expect_breakdown_pulled }
    assert_equal(['e'], globber.scala_files)
  end

  def test_markdown_files
    globber = get_test_object { mock_files_found }
    assert_equal(['foo/b.md'], globber.markdown_files)
  end
end
