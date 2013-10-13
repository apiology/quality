require 'simplecov'
SimpleCov.start
SimpleCov.refuse_coverage_drop
require_relative '../../lib/quality/rake/task'
require 'test/unit'
require 'mocha/setup'
