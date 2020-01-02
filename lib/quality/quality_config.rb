# frozen_string_literal: true

require_relative 'threshold'

module Quality
  # TODO: Figure out name, how this relates to Quality::Config - document that
  # Configuration of quality gem
  class QualityConfig
    def initialize(tool_name,
                   quality_threshold: QualityThreshold.new(tool_name))
      @quality_threshold = quality_threshold
    end

    def high_water_mark
      @quality_threshold.threshold
    end

    # TODO: Should this live in threshold?
    def under_limit?(total_lines)
      total_lines <= @quality_threshold.threshold
    end
  end
end
