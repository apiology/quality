require 'simplecov'
require 'coveralls'
SimpleCov.formatter =
  SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter,
  ]

SimpleCov.start do
  add_filter 'vendor' # Don't include vendored stuff
end
SimpleCov.refuse_coverage_drop
require_relative '../../lib/quality/rake/task'
require 'minitest/autorun'
require 'mocha/setup'

def get_initializer_mocks(clazz, skip_these_keys: [])
  parameters = clazz.instance_method(:initialize).parameters
  named_parameters = parameters.select do |name, _value|
    name == :key
  end
  mock_syms = named_parameters.map { |_name, value| value } - skip_these_keys

  # create a hash of argument name to a new mock
  Hash[*mock_syms.map { |sym| [sym, mock(sym.to_s)] }.flatten]
end
