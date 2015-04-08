# ; -*-Ruby-*-
# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.join(File.dirname(__FILE__), 'lib')
require 'quality/version'

Gem::Specification.new do |s|
  s.name = %q(quality)
  s.version = Quality::VERSION

  s.authors = ['Vince Broz']
  # s.default_executable = %q{quality}
  s.description = %q(Quality is a tool that runs quality checks on Ruby
code using rubocop, cane, reek, flog and flay, and makes sure
your numbers don't get any worse over time.

)
  s.email = ['vince@broz.cc']
  # s.executables = ["quality"]
  # s.extra_rdoc_files = ["CHANGELOG", "License.txt"]
  s.license = 'MIT'
  s.files = Dir['License.txt', 'README.md',
                'Rakefile',
                # "bin/quality",
                '{lib}/**/*',
                'quality.gemspec'] & `git ls-files -z`.split("\0")
  # s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ['lib']
  s.homepage = %q(http://github.com/apiology/quality)
  # s.rubyforge_project = %q{quality}
  s.rubygems_version = %q(1.3.6)
  s.summary = %q(Code quality tools for Ruby)

  s.add_runtime_dependency(%q(cane), ['>= 2.6'])
  s.add_runtime_dependency(%q(reek), ['>= 1.3.4'])
  s.add_runtime_dependency(%q(flog), ['>= 4.1.1'])
  # flay 2.6.0 contained a command-line-parsing issue
  s.add_runtime_dependency(%q(flay), ['>= 2.4', '!= 2.6.0'])
  s.add_runtime_dependency(%q(rubocop))
  s.add_runtime_dependency(%q(bigfiles))
  s.add_runtime_dependency(%q(punchlist))
  s.add_runtime_dependency(%q(quality))

  # need above this version to support Ruby 2.0 syntax
  s.add_runtime_dependency(%q(ruby_parser), ['>= 3.2.2'])

  # cane has an unadvertised dependency on json
  s.add_runtime_dependency(%q(json))

  s.add_development_dependency(%q(bundler), ['>= 1.1'])
  s.add_development_dependency(%q(rake))
  s.add_development_dependency(%q(simplecov))
  s.add_development_dependency(%q(mocha))
end
