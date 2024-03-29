# Quality -- code quality ratchet for Ruby

[![CircleCI](https://circleci.com/gh/apiology/quality.svg?style=svg)](https://circleci.com/gh/apiology/quality)

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

See [DOCKER.md](DOCKER.md) for info.

## How to use - as part of a Ruby-based Rakefile

```bash
pip install flake8
brew install cmake icu4c shellcheck scalastyle # macOS
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

## Pronto

To help better understand which warnings came from your current set of
changes, consider using
[Pronto](https://github.com/prontolabs/pronto), which provides
incremental reporting from different quality tools, and can add
comments directly to PR reviews.  You can see an example in this
project's
[Rakefile](https://github.com/apiology/quality/blob/main/Rakefile)

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
breaking your build.  This lock affects both the Docker-based quality
gem (helping to ensure build stability for floating major versions) as
well as the gem when included directly in your project's gems.

Expect your build to break on major upgrades if you use RuboCop.

## Supported Ruby Versions

Tested against Ruby >=2.2--does not support Ruby 1.9.x or JRuby.

## Contributions

This project, as with all others, rests on the shoulders of a broad
ecosystem supported by many volunteers doing thankless work, along
with specific contributors.

In particular I'd like to call out:

* [Audrey Roy Greenfeld](https://github.com/audreyfeldroy) for the
  cookiecutter tool and associated examples, which keep my many
  projects building with shared boilerplate with a minimum of fuss.


## License

Licensed under the MIT license.
