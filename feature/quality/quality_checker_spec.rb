# frozen_string_literal: true

require_relative 'feature_helper'
require 'quality/quality_checker'

describe Quality::QualityChecker do
  it 'has an example feature spec' do
    expect(exec_io('echo test')).to eq("test\n")
  end
end
