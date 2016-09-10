[![Build Status](https://travis-ci.org/apiology/quality.png)](https://travis-ci.org/apiology/quality)
[![Coverage Status](https://coveralls.io/repos/apiology/quality/badge.png?branch=master)](https://coveralls.io/r/apiology/quality?branch=master)


# Quality -- code quality ratchet for Ruby

##Overview

Quality is a tool that runs quality checks on code in git repos using
different analysis tools and makes sure your numbers don't get any
worse over time.

## Why

See [this post](http://blog.apiology.cc/2014/06/scalable-quality-part-1.html) or [these slides](https://docs.google.com/presentation/d/1Op4FH34-enm8luEIuAAVLkuAJ-sB4LKaMm57RJzvfeI/edit#slide) for more information on the problem the quality gem solves.

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
* [pep8](https://pypi.python.org/pypi/pep8)
* [punchlist](https://github.com/apiology/punchlist)
* [rails_best_practices](https://github.com/railsbp/rails_best_practices)
* [reek](https://github.com/troessner/reek)
* [rubocop](https://github.com/bbatsov/rubocop)

## How to use - using Docker

These basic steps assume you have a working Docker installation.

```
docker run -v `pwd`:/usr/app apiology/quality:latest
```

If you'd like to customize, you can link in your own Rakefile like this:

```
docker run -v `pwd`:/usr/app -v `pwd`/Rakefile.quality:/usr/quality/Rakefile apiology/quality:latest
```

The default 'latest' tag contains the Ruby tools in a relatively small image.  You can also get additional tools (see `Dockerfile.jumbo` in this directory) by using the tag `jumbo-`(version) (e.g., jumbo-latest, jumbo-x.y.z, etc)


## How to use - as part of a Ruby-based Rakefile

```bash
$ brew install cmake icu4c # OS X
$ gem install quality
```

or in your Gemfile:

```ruby
group :development do
  gem 'quality'
end
```
and then:

```bash
$ bundle install
```

Once you have the gem, configure your Rakefile like this:

```ruby
require 'quality/rake/task'

Quality::Rake::Task.new
```

Then run:

```bash
$ rake quality
```

If you want to ratchet up the quality and force yourself to improve
code, run:

```bash
$ rake ratchet
```

## Configuration options

```ruby
Quality::Rake::Task.new do |t|
  # Name of quality task.
  # Defaults to :quality.
  t.quality_name = 'quality'

  # Name of ratchet task.
  # Defaults to :ratchet.
  t.ratchet_name = 'ratchet'

  # Array of strings describing tools to be skipped--e.g., ["cane"]
  #
  # Defaults to []
  t.skip_tools = []

  # Log command executation
  #
  # Defaults to false
  t.verbose = false

  # Relative path to output directory where *_high_water_mark
  # files will be read/written
  #
  # Defaults to 'metrics'
  t.output_dir = 'metrics'

  # Pipe-separated regexp string describing what to look for in
  # files as 'todo'-like 'punchlist' comments.
  #
  # Defaults to 'XXX|TODO'
  t.punchlist_regexp = 'XXX|TODO'

  # Exclude the specified list of files--defaults to ['db/schema.rb']
  t.exclude_files = ['lib/whatever/imported_file.rb',
                     'lib/vendor/someone_else_fault.rb']

  # Alternately, express it as a glob:

  # Exclude the specified list of files
  t.source_files_exclude_glob =
    '{lib/whatever/imported_file.rb,lib/vendor/**/*.rb}'

  #
  # For configuration on classifying files as the correct language,
  # see https://github.com/github/linguist
  #
end
```

## Vendored files

Quality uses GitHub's [linguist](https://github.com/github/linguist) gem to find and classify source files to analyze.  In addition to the `exclude_files` and `source_files_exclude_glob` options in Quality, you can refer to Linguists's documentation on [overrides](https://github.com/github/linguist#overrides) to use the `gitattributes` file to mark files as vendored, at which point Quality will not try to analyze them.
  

## Code coverage

You can pull a similar trick with code coverage using SimpleCov in Ruby--put 'simplecov' in your Gemfile, and add the code below into your test_helper.rb or spec_helper.rb.

```
require 'simplecov'
SimpleCov.start
SimpleCov.refuse_coverage_drop
```

After your first run, check in your coverage/.last_run.json.

## Caveats

Quality uses [semantic versioning](http://semver.org/)--any incompatible changes (including new tools being added) will come out as major number updates.

## Supported Ruby Versions

Tested against Ruby >=2.2--does not support Ruby 1.9.x or JRuby.

## Contributing

* Fork the repo
* Create a feature branch
* Submit a github pull request

Many thanks to all contributors, especially [@andyw8](https://github.com/andyw8), who has contributed some great improvements.

### Learn More

* Browse the code or install the latest development version from [https://github.com/apiology/quality/tree](https://github.com/apiology/quality/tree)

## License

Licensed under the MIT license.
