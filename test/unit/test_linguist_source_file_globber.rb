require_relative 'test_helper'

# Test the LinguistSourceFileGlobber class
class TestLinguistSourceFileGlobber < MiniTest::Test
  let_mock :target, :blob_a_rb, :blob_b_md

  def test_source_and_doc_files
    globber = get_test_object do |mocks|
      mocks[:project]
        .expects(:breakdown_by_file)
        .returns('FizzBuzzLang' => ['a.rb'])
      mocks[:commit].expects(:target).returns(target)
      target.expects(:tree).returns([{ type: :blob, name: 'a.rb' },
                                     { type: :blob, name: 'b.md' }])
      mocks[:file_blob]
        .expects(:new)
        .with('a.rb', mocks[:pwd])
        .returns(blob_a_rb)
      blob_a_rb.expects(:generated?).returns(false)
      blob_a_rb.expects(:vendored?).returns(false)
      blob_a_rb.expects(:documentation?).returns(false)
      blob_a_rb.expects(:language).returns('Ruby')

      mocks[:file_blob]
        .expects(:new)
        .with('b.md', mocks[:pwd])
        .returns(blob_b_md)
      blob_b_md.expects(:generated?).returns(false)
      blob_b_md.expects(:vendored?).returns(false)
      blob_b_md.expects(:documentation?).returns(true)
    end
    assert_equal(['a.rb', 'b.md'], globber.source_and_doc_files)

  end

  def get_test_object(&twiddle_mocks)
    mocks = get_initializer_mocks(Quality::LinguistSourceFileGlobber)
    yield mocks unless twiddle_mocks.nil?
    Quality::LinguistSourceFileGlobber.new(mocks)
  end
end
