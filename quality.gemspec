# ; -*-Ruby-*-
# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.join(File.dirname(__FILE__), 'lib')
require 'quality/version'

Gem::Specification.new do |s|
  s.name = 'quality'
  s.version = Quality::VERSION

  s.authors = ['Vince Broz']
  # s.default_executable = %q{quality}
  s.description =
    'Quality is a tool that runs quality checks on your code using ' \
    "community tools, and makes sure your numbers don't get any " \
    "worse over time. Just add 'rake quality' as part of your " \
    'Continuous Integration'
  s.email = ['vince@broz.cc']
  # s.executables = ["quality"]
  # s.extra_rdoc_files = ["CHANGELOG", "License.txt"]
  s.license = 'MIT'
  s.files = Dir['CODE_OF_CONDUCT.md', 'LICENSE.txt', 'README.md',
                '{lib}/quality.rb',
                '{lib}/quality/**/*.rb',
                'quality.gemspec']
  # s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ['lib']
  s.homepage = 'http://github.com/apiology/quality'
  # s.rubyforge_project = %q{quality}
  s.rubygems_version = '1.3.6'
  s.summary = 'Code quality tools for Ruby'

  s.add_runtime_dependency('activesupport')
  s.add_runtime_dependency('source_finder', ['>=2.3.0'])
  s.add_runtime_dependency('cane', ['>= 2.6'])
  s.add_runtime_dependency('reek', ['>= 1.3.4'])
  s.add_runtime_dependency('flog', ['>= 4.1.1'])
  # flay 2.6.0 contained a command-line-parsing issue
  s.add_runtime_dependency('flay', ['>= 2.4', '!= 2.6.0'])
  s.add_runtime_dependency('rubocop')
  s.add_runtime_dependency('rubocop-rspec')
  s.add_runtime_dependency('bigfiles', ['>= 0.1'])
  s.add_runtime_dependency('punchlist', ['>= 1.1'])
  s.add_runtime_dependency('brakeman')
  s.add_runtime_dependency('rails_best_practices')

  # need above 3.2.2 to support Ruby 2.0 syntax
  #
  # 3.6.6 was a buggy release, see seattlerb/ruby_parser#183
  s.add_runtime_dependency('ruby_parser', ['>= 3.2.2', '!= 3.6.6'])

  # cane has an unadvertised dependency on json
  s.add_runtime_dependency('json')

  s.add_development_dependency('bundler', ['>= 1.1'])
  # Workaround for
  # https://github.com/bundler/bundler/issues/3401
  s.add_development_dependency('rake', ['!= 10.4.2'])
  s.add_development_dependency('simplecov')
  s.add_development_dependency('mocha')
  s.add_development_dependency('minitest', ['~> 5'])
end
