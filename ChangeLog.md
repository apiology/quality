# Changelog

## Changes since Quality 1.3.1

* Include 'app' in default directories covered, for rails fans
* Remove auto-git-commit from 'rake ratchet'
* Cane now respects configured ruby directories by default
* Lots of internal maintainability improvements!
* Change default output directory to 'metrics', and create directory if needed

## Changes since Quality 2.0.0

* Exclude buggy version of 'flay'

## Changes since Quality 2.0.1

* Add .verbose option

## Changes since Quality 2.1.0

* Cane is now limited to the files specified by 'ruby_dirs'

## Changes since Quality 2.1.1

* Added 'BigFiles' to limit the size of the largest files in your project.
* Remove support for Ruby 1.9.x

## Changes since Quality 3.0.0

* Fix to bigfiles support to honor glob

## Changes since Quality 3.1.0

* Add Rakefile to default Ruby glob
* Add configurable source_dirs for non-Ruby quality inspection

## Changes since Quality 4.0.0

* Fix shell escaping bug with cane

## Changes since Quality 4.0.1

* Fix bug in source_dirs configuration

## Changes since Quality 4.0.2

* Added 'punchlist'

## Changes since Quality 5.0.0

* Avoid buggy ruby_parser release

## Changes since Quality 5.0.1

* Add support for Clojure/ClojureScript files in bigfiles/punchlist

## Changes since Quality 6.0.0

* Add Rakefile to default source files (configurable via extra_files
  parameter)
* Add basic support for Scala and JavaScript via language-independent
  tools like bigfiles and punchlist

## Changes since Quality 7.0.0

* Add support for .rake files as Ruby language

## Changes since Quality 8.0.0

* Allow configuration of punchlist regexp

## Changes since Quality 8.1.0

* Fix 'extra_files' configuration not being globbed correctly
  resulting in Rakefile not being searched for issues

## Changes since Quality 8.1.1

* Add Dockerfile as a t.extra_files entry.
* Add entries and make ruby_file_extensions and
  source_file_extensions configurable.

## Changes since Quality 9.0.0

* Fix #27: Add separate extra_ruby_files option

## Changes since Quality 10.0.0

* Include files in root directory by default.

## Changes since Quality 11.0.0

* Include .gemspec files

## Changes since Quality 12.0.0

* Include `.*` as well as `*` in glob, so files like '.rubocop.yml'
  can be searched.

## Changes since Quality 13.0.0

* Allow for quality tools that bomb out when there's no code that it
  cares about to check
* Add Brakeman support (github issue #30)
* Add workarounds for some rvm/bundler/rake integration issues
* Fix bug in error output on exit

## Changes since Quality 14.0.0

* Add exclude_files configuration
* Fix undercounting of flay issues

## Changes since Quality 14.1.0

* Add rails_best_practices gem

## Changes since Quality 15.0.0

* Update source_finder dependency and start to make config variable
  names a little more sane

## Changes since Quality 15.0.1

* Recognize .md files for punchlist

## Changes since Quality 16.0.0

* Fix broken source_file_extensions configuration

## Changes since Quality 16.0.1

* Add rubocop-rspec

## Changes since Quality 17.0.0

* Exclude db/schema.db, a generated file.

## Changes since Quality 17.1.1

* Add working source_files_exclude_glob support

## Changes since Quality 17.2.0

* Add ESLint support for JS
* Extra source files config matches docs
* Add PEP8 support for Python
* Fix gemspec file inclusion bugs

## Changes since Quality 18.0.0

* Fix pep8 bug when no python files found

## Changes since Quality 18.0.1

* Add JSCS support for JS

## Changes since Quality 19.0.0

* Give a diagnostic when JSCS not configured

## Changes since Quality 19.1.0

* Fix flag name in diagnostic

## Changes since Quality 19.1.1

* Fix bug keeping jscs from running

## Changes since Quality 19.1.2

* Bump source_finder requirement

## Changes since Quality 19.1.3

* Exclude vendor files

## Changes since Quality 19.2.0

* Fix JSCS-related bug
* Fix configuration bug

## Changes since Quality 20.0.1

* Fix bug in pep8 parsing for Python

## Changes since Quality 20.0.2

* Remove use of deprecated method - thanks, gerrywastaken!

## Changes since Quality 20.0.3

* Add configurability of python paths

## Changes since Quality 27.0.0

* Add configurability of scalacheck config

## Changes since Quality 27.3.0

* Correctly detect exclude glob in punchlist

## Changes since Quality 27.3.1

* Add ability to set minimum threshold for values to ratchet to, and
  default minimum threshold of 300 for bigfiles.

## Changes since Quality 27.4.0

* Bumped and locked in RuboCop version.  RuboCop version will not change between
  quality gem major versions.
* Remove support for Ruby 2.1
* Add note on Rails and Rakefile (thanks, @andresakata!)

## Changes since Quality 28.0.0

* RuboCop 0.52.1
* Tested against Ruby 2.5

## Changes since Quality 29.0.0

* added --force-exclusion command line for RuboCop
* RuboCop 0.54.0

## Changes since Quality 30.0.0

* pep8 -> pycodestyle tool rename
* python 2.7 -> 3.6 in Docker image
* Force-update rest-client to avoid CVEs

## Changes since Quality 31.0.0

* Work around pycodestyle/flake8 interaction issue

## Changes since Quality 31.0.1

* Add initial pronto support to Rockerfile
* Switch internal builds to CircleCI 2.0
* Use Ruby 2.3 for internal builds
* Work around flake8/pycodestyle interaction issue

## Changes since Quality 31.1.0

* Drop pronto-eslint from image, since no JS installed
* Add pre-caching step for quality gem dependencies
* Allow individual tools to be run via Docker

## Changes since Quality 31.2.1

* Default Docker runs to non-verbose
* Output full command-line upon failure
* Fix command-output to split lines at 80 columns.
