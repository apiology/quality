# frozen_string_literal: true

require 'simplecov'

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
]
SimpleCov.start do
  # this dir used by TravisCI
  add_filter 'vendor'
end

RSpec.configure do |config|
  config.order = 'random'
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
