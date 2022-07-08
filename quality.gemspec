# coding: ascii
# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'quality/version'

Gem::Specification.new do |spec|
  spec.name          = 'quality'
  spec.version       = Quality::VERSION
  spec.authors       = ['Vince Broz']
  spec.description =
    "Quality is a tool that runs quality checks on your code using " \
    "community tools, and makes sure your numbers don't get any " \
    "worse over time. Just add 'rake quality' as part of your " \
    "Continuous Integration"
  spec.email         = ['vince@broz.cc']
  spec.summary       = 'Code quality ratchet for Ruby'
  spec.homepage      = 'https://github.com/apiology/quality'
  spec.license       = 'MIT license'
  spec.required_ruby_version = '>= 2.6'
  spec.files = Dir['CODE_OF_CONDUCT.md', 'LICENSE.txt', 'README.md',
                   '{lib}/quality.rb',
                   '{lib}/quality/**/*.rb',
                   'quality.gemspec']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bump'
  spec.add_development_dependency('bundler', ['>= 1.1'])
  spec.add_development_dependency 'mdl'
  # Workaround for
  # https://github.com/bundler/bundler/issues/3401
  spec.add_development_dependency('minitest', ['~> 5'])
  spec.add_development_dependency('mocha')
  # 0.58.0 and 0.57.0 don't seem super compatible with signatures, and
  # magit doesn't seem to want to use the bundled version at the moment,
  # so let's favor the more recent version...
  spec.add_development_dependency 'overcommit', ['>=0.58.0']
  spec.add_development_dependency('pronto', '>=0.11')
  spec.add_development_dependency('pronto-bigfiles')
  # spec.add_development_dependency('pronto-flake8') # does not yet support pronto 0.11
  spec.add_development_dependency('pronto-punchlist')
  spec.add_development_dependency('pronto-rubocop')
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '>=3.4'
  # ensure version with branch coverage
  spec.add_development_dependency 'simplecov', ['>=0.18.0']
  spec.add_development_dependency 'simplecov-lcov'
  spec.add_development_dependency 'undercover'

  spec.add_runtime_dependency('activesupport')
  spec.add_runtime_dependency('bundler-audit')
  spec.add_runtime_dependency('cane', ['>= 2.6'])
  spec.add_runtime_dependency('flog', ['>= 4.1.1'])
  spec.add_runtime_dependency('github-linguist')
  spec.add_runtime_dependency('reek', ['>= 1.3.4'])
  # flay 2.6.0 contained a command-line-parsing issue
  spec.add_runtime_dependency('flay', ['>= 2.4', '!= 2.6.0'])
  # avoid security issues - CVE-2015-1820, CVE-2015-3448
  spec.add_runtime_dependency('rest-client', ['>= 1.8.0'])
  #
  # per version advice here - locks quality gem version with rubocop
  # version to avoid unexplained metric-changing surprises:
  #
  # https://github.com/bbatsov/rubocop#installation
  spec.add_runtime_dependency('mdl')
  spec.add_runtime_dependency('rubocop', '~> 1.22.0')
  # 0.2.0 had a fatal bug
  # 0.3.0 introduces config files
  spec.add_runtime_dependency('bigfiles', ['>= 0.3.0', '!= 0.2.0'])
  spec.add_runtime_dependency('brakeman')
  spec.add_runtime_dependency('high_water_mark')
  spec.add_runtime_dependency('punchlist', ['>= 1.1'])
  spec.add_runtime_dependency('rails_best_practices')
  spec.add_runtime_dependency('rubocop-minitest')
  spec.add_runtime_dependency('rubocop-rake')
  # 1.19.0 was a RuboCop 0.51.0 compatibility release
  spec.add_runtime_dependency('faraday', ['~>1'])
  spec.add_runtime_dependency('rubocop-rspec', ['>=1.19.0'])

  # need above 3.2.2 to support Ruby 2.0 syntax
  #
  # 3.6.6 was a buggy release, see seattlerb/ruby_parser#183
  spec.add_runtime_dependency('ruby_parser', ['>= 3.2.2', '!= 3.6.6'])

  # cane has an unadvertised dependency on json
  spec.add_runtime_dependency('json')
end
