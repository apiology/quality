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
  add_filter 'vendor' # Don't include vendored stuff
  track_files '{app,lib}/**/*.rb'
  enable_coverage(:branch) # Report branch coverage to trigger branch-level undercover warnings
end
SimpleCov.refuse_coverage_drop
require_relative '../../lib/quality/rake/task'
require 'minitest/autorun'
require 'mocha/minitest'

def get_initializer_mocks(clazz, skip_these_keys: [])
  parameters = clazz.instance_method(:initialize).parameters
  named_parameters = parameters.select do |name, _value|
    name == :key
  end
  mock_syms = named_parameters.map { |_name, value| value } - skip_these_keys

  # create a hash of argument name to a new mock
  Hash[*mock_syms.map { |sym| [sym, mock(sym.to_s)] }.flatten]
end

def let_single_mock(mock_sym)
  define_method(mock_sym.to_s) do
    var = "@#{mock_sym}".to_sym
    if instance_variable_defined?(var)
      instance_variable_get var
    else
      mock = mock(mock_sym.to_s)
      instance_variable_set var, mock
      mock
    end
  end
end

def let_mock(*mocks)
  mocks.each do |mock_sym|
    let_single_mock(mock_sym)
  end
end
