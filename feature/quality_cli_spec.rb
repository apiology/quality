require_relative 'feature_helper'

describe 'quality' do
  it 'has an example feature spec' do
    expect(exec_io 'echo test').to eq("test\n")
  end
end
