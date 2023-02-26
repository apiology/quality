# frozen_string_literal: true

require 'simplecov'
require 'simplecov-lcov'

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter,
  ]
)
SimpleCov.start do
  # this dir used by CircleCI
  add_filter 'vendor'
  track_files '{app,lib}/**/*.rb'
  enable_coverage(:branch) # Report branch coverage to trigger branch-level undercover warnings
end

require 'webmock/rspec'

RSpec.configure do |config|
  config.order = 'random'
end
