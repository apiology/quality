# frozen_string_literal: true

require 'quality/config'

describe Quality::Config do
  let(:globber) { instance_double(Quality::LinguistSourceFileGlobber) }
  let(:dir) { class_double(Dir) }
  let(:config) do
    described_class.new(source_file_globber: globber, dir: dir)
  end

  describe '#minimum_threshold' do
    context 'with no previous invocation' do
      subject { config.minimum_threshold }

      it { is_expected.to eq(bigfiles: 300) }
    end
  end

  #     let(:cmd) { 'cmd' }
  #     let(:args) { 'arg1 arg2' }

  #     it { is_expected.to eq('cmd arg1 arg2') }
  #   end
  # end
end
