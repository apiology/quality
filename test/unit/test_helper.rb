require 'simplecov'
SimpleCov.start do
  add_filter 'vendor' # Don't include vendored stuff
end
SimpleCov.refuse_coverage_drop
require_relative '../../lib/quality/rake/task'
require 'minitest/autorun'
require 'mocha/setup'
