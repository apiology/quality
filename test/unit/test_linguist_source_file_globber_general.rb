# frozen_string_literal: true

require_relative 'test_linguist_source_file_globber'

# Test the LinguistSourceFileGlobber class
class TestLinguistSourceFileGlobberGeneral < TestLinguistSourceFileGlobber
  def test_source_and_doc_files
    globber = get_test_object { mock_files_found }
    assert_equal(['a.rb', 'foo/b.md', 'c', 'd.jsx'],
                 globber.source_and_doc_files)
  end

  def test_source_files
    globber = get_test_object { mock_files_found }
    assert_equal(['a.rb', 'c', 'd.jsx'], globber.source_files)
  end
end
