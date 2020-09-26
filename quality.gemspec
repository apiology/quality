# frozen_string_literal: true

# ; -*-Ruby-*-

$LOAD_PATH.push File.join(File.dirname(__FILE__), 'lib')
require 'quality/version'

Gem::Specification.new do |s|
  s.name = 'quality'
  s.version = Quality::VERSION

  s.authors = ['Vince Broz']
  s.description =
    "Quality is a tool that runs quality checks on your code using " \
    "community tools, and makes sure your numbers don't get any " \
    "worse over time. Just add 'rake quality' as part of your " \
    "Continuous Integration"
  s.email = ['vince@broz.cc']
  s.license = 'MIT'
  s.files = Dir['CODE_OF_CONDUCT.md', 'LICENSE.txt', 'README.md',
                '{lib}/quality.rb',
                '{lib}/quality/**/*.rb',
                'quality.gemspec']
  s.require_paths = ['lib']
  s.homepage = 'http://github.com/apiology/quality'
  s.rubygems_version = '1.3.6'
  s.summary = 'Code quality tools for Ruby'

  s.add_runtime_dependency('activesupport')
  s.add_runtime_dependency('bundler-audit')
  s.add_runtime_dependency('cane', ['>= 2.6'])
  s.add_runtime_dependency('flog', ['>= 4.1.1'])
  s.add_runtime_dependency('github-linguist')
  s.add_runtime_dependency('reek', ['>= 1.3.4'])
  # flay 2.6.0 contained a command-line-parsing issue
  s.add_runtime_dependency('flay', ['>= 2.4', '!= 2.6.0'])
  # avoid security issues - CVE-2015-1820, CVE-2015-3448
  s.add_runtime_dependency('rest-client', ['>= 1.8.0'])
  #
  # per version advice here - locks quality gem version with rubocop
  # version to avoid unexplained metric-changing surprises:
  #
  # https://github.com/bbatsov/rubocop#installation
  s.add_runtime_dependency('mdl')
  s.add_runtime_dependency('rubocop', '~> 0.92.0')
  # 0.2.0 had a fatal bug
  s.add_runtime_dependency('bigfiles', ['>= 0.1', '!= 0.2.0'])
  s.add_runtime_dependency('brakeman')
  s.add_runtime_dependency('high_water_mark')
  s.add_runtime_dependency('punchlist', ['>= 1.1'])
  s.add_runtime_dependency('rails_best_practices')
  s.add_runtime_dependency('rubocop-minitest')
  s.add_runtime_dependency('rubocop-rake')
  # 1.19.0 was a RuboCop 0.51.0 compatibility release
  s.add_runtime_dependency('rubocop-rspec', ['>=1.19.0'])
  # not directly required - this is to workaround this issue:
  #  https://github.com/octokit/octokit.rb/issues/1177
  #
  # This causes:
  #  "uninitialized constant Faraday::Error::ClientError (NameError)"
  s.add_runtime_dependency('faraday', ['<1'])

  # need above 3.2.2 to support Ruby 2.0 syntax
  #
  # 3.6.6 was a buggy release, see seattlerb/ruby_parser#183
  s.add_runtime_dependency('ruby_parser', ['>= 3.2.2', '!= 3.6.6'])

  # cane has an unadvertised dependency on json
  s.add_runtime_dependency('json')

  s.add_development_dependency('bundler', ['>= 1.1'])
  # Workaround for
  # https://github.com/bundler/bundler/issues/3401
  s.add_development_dependency('minitest', ['~> 5'])
  s.add_development_dependency('mocha')
  s.add_development_dependency('pronto')
  s.add_development_dependency('pronto-bigfiles')
  s.add_development_dependency('pronto-flake8')
  s.add_development_dependency('pronto-punchlist')
  s.add_development_dependency('pronto-rubocop')
  s.add_development_dependency('rake', ['!= 10.4.2'])
  s.add_development_dependency('rspec')
end
