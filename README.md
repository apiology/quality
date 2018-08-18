# Quality -- code quality ratchet for Ruby

[![Build Status](https://travis-ci.org/apiology/quality.png)](https://travis-ci.org/apiology/quality)
[![Coverage Status](https://coveralls.io/repos/apiology/quality/badge.png?branch=master)](https://coveralls.io/r/apiology/quality?branch=master)

## Overview

Quality is a tool that runs quality checks on code in git repos using
different analysis tools and makes sure your numbers don't get any
worse over time.

## Why

See [this post](http://blog.apiology.cc/2014/06/scalable-quality-part-1.html)
or [these slides](https://docs.google.com/presentation/d/1Op4FH34-enm8luEIuAAVLkuAJ-sB4LKaMm57RJzvfeI/edit#slide)
for more information on the problem the quality gem solves.

### Tools

Quality makes use of the following other tools, which do the actual checking:

* [bigfiles](https://github.com/apiology/bigfiles)
* [brakeman](http://brakemanscanner.org/)
* [bundler_audit](https://github.com/rubysec/bundler-audit)
* [cane](https://github.com/square/cane)
* [eslint](http://eslint.org/)
* [flake8](https://pypi.python.org/pypi/flake8)
* [flay](https://github.com/seattlerb/flay)
* [flog](https://github.com/seattlerb/flog)
* [jscs](http://jscs.info/)
* [pycodestyle](https://github.com/PyCQA/pycodestyle)
* [punchlist](https://github.com/apiology/punchlist)
* [rails_best_practices](https://github.com/railsbp/rails_best_practices)
* [reek](https://github.com/troessner/reek)
* [rubocop](https://github.com/bbatsov/rubocop)

## How to use - using Docker

```bash
docker run -v `pwd`:/usr/app apiology/quality:latest
```

If you'd like to customize, you can link in your own Rakefile like this:

```bash
docker run -v `pwd`:/usr/app -v `pwd`/Rakefile.quality:/usr/quality/Rakefile apiology/quality:latest
```

The default 'latest' tag contains the Ruby tools in a relatively small
image.  Likewise, you can point to individual versions (as `x.y.z`,
`x.y`, or `x` with Docker tags).

You can also get additional tools (see `Rockerfile` in
this directory) by using the tag `prefix-`(version) (e.g.,
`prefix-latest`, `prefix-x.y.z`, etc).

Supported images:

* (default): Ruby support
* `python-<version>`: Plus support for Python tools
* `shellcheck-<version>`: Plus support for running shellcheck against shell scripts
* `jumbo-<version>`: Plus support for scalastyle.

To run an individual tool, you can run like this:

```bash
docker run -v `pwd`:/usr/app apiology/quality:latest rubocop
```

## How to use - as part of a Ruby-based Rakefile

```bash
pip install 'pycodestyle<2.4.0' flake8
brew install cmake icu4c shellcheck scalastyle # OS X
gem install quality
```

or in your Gemfile:

```ruby
group :development do
  gem 'quality'
end
```

and then:

```bash
bundle install
```

Once you have the gem, configure your Rakefile like this:

```ruby
require 'quality/rake/task'

Quality::Rake::Task.new
```

If you're using Rails, you must check your environment in your
Rakefile.

```ruby
if Rails.env.development?
  require 'quality/rake/task'

  Quality::Rake::Task.new
end
```

Then run:

```bash
rake quality
```

If you want to ratchet up the quality and force yourself to improve
code, run:

```bash
rake ratchet
```

## Configuration options

See [CONFIGURATION.md](CONFIGURATION.md)

## Vendored files

Quality uses GitHub's [linguist](https://github.com/github/linguist)
gem to find and classify source files to analyze.  In addition to
the `exclude_files` and `source_files_exclude_glob`
options in Quality, you can refer to
Linguists's documentation on [overrides](https://github.com/github/linguist#overrides)
to use the `gitattributes` file to mark files as vendored, at which point
Quality will not try to analyze them.

## Code coverage

You can pull a similar trick with code coverage using SimpleCov in
Ruby--put 'simplecov' in your Gemfile, and add the code below into
your test_helper.rb or spec_helper.rb.

```ruby
require 'simplecov'
SimpleCov.start
SimpleCov.refuse_coverage_drop
```

After your first run, check in your coverage/.last_run.json.

## Build

On OS X, you may
see [build](https://github.com/brianmario/charlock_holmes/issues/117)
failures in charlock_holmes.  To work around, if you are
using
[Homebrew](https://github.com/brianmario/charlock_holmes#homebrew):

```sh
bundle config build.charlock_holmes --with-cxxflags=-std=c++11 --with-icu-dir=/usr/local/opt/icu4c
```

## Caveats

Quality uses [semantic versioning](http://semver.org/)--any incompatible changes
(including new tools being added) will come out as major number
updates.

This includes RuboCop upgrades - the quality gem locks in a specific
minor version of RuboCop to avoid your metrics being bumped and
breaking your build.

Expect your build to break on major upgrades if you use RuboCop.

## Supported Ruby Versions

Tested against Ruby >=2.2--does not support Ruby 1.9.x or JRuby.

## Contributing

* Fork the repo
* Create a feature branch
* Submit a github pull request

Many thanks to all contributors, especially [@andyw8](https://github.com/andyw8),
who has contributed some great improvements.

## License

Licensed under the MIT license.
