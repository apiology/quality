# frozen_string_literal: true

require_relative '../../spec_helper'
require 'quality/tools/bigfiles'
require 'quality/runner'

describe Quality::Tools::Bigfiles do
  let(:runner) { instance_double(Quality::Runner) }
  let(:bigfiles) { described_class.new(runner) }

  it 'can be created' do
    expect(bigfiles).not_to be_nil
  end
end
