# frozen_string_literal: true

require 'quality/threshold'

describe Quality::Threshold do
  let(:quality_threshold) do
    described_class.new(tool_name,
                        count_file: count_file,
                        count_io: count_io)
  end
  let(:count_file) { class_double(File) }
  let(:count_io) { class_double(IO) }

  describe '#threshold' do
    subject { quality_threshold.threshold }

    let(:metrics_filename) { "metrics/#{tool_name}_high_water_mark" }

    before do
      allow(count_file).to receive(:exist?).with(metrics_filename) do
        file_exists
      end
      if file_exists
        allow(count_io).to receive(:read).with(metrics_filename) do
          high_water_mark.to_s
        end
      end
    end

    context 'when high water mark file exists' do
      let(:tool_name) { 'bigfiles' }
      let(:file_exists) { true }
      let(:high_water_mark) { 923 }

      it { is_expected.to be high_water_mark }
    end

    context 'when high water mark file does not exist with bigfiles' do
      let(:file_exists) { false }
      let(:tool_name) { 'bigfiles' }

      it { is_expected.to be 300 }
    end

    context 'when high water mark file does not exist with another tool' do
      let(:file_exists) { false }
      let(:tool_name) { 'another_tool' }

      it { is_expected.to be 0 }
    end
  end
end
