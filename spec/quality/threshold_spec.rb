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
  let(:tool_name) { 'foo' }
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

  describe '#threshold' do
    subject { quality_threshold.threshold }

    context 'when high water mark file exists' do
      let(:file_exists) { true }
      let(:high_water_mark) { 923 }

      it { is_expected.to be high_water_mark }
    end

    context 'when high water mark file does not exist' do
      let(:file_exists) { false }

      it { is_expected.to be nil }
    end
  end

  describe '#write_violations' do
    let(:new_violations) { instance_double(Integer) }
    let(:file_exists) { true }
    let(:file) { instance_double(File) }

    before do
      allow(count_file).to receive(:open).with(metrics_filename, 'w')
                                         .and_yield(file)
      allow(file).to receive(:write).with(new_violations.to_s + "\n")
    end

    it 'is written' do
      quality_threshold.write_violations(new_violations)
      expect(file).to have_received(:write).with(new_violations.to_s + "\n")
    end
  end
end
