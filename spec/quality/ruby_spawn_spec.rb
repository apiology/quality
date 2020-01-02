# frozen_string_literal: true

require 'quality/ruby_spawn'

describe Quality::RubySpawn do
  let(:ruby_spawn) do
    described_class.new(cmd, args)
  end

  describe '#invocation' do
    context 'with args' do
      subject { ruby_spawn.invocation }

      let(:cmd) { 'cmd' }
      let(:args) { 'arg1 arg2' }

      it { is_expected.to eq('cmd arg1 arg2') }
    end
  end
end
