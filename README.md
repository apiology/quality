[![Build Status](https://travis-ci.org/apiology/quality.png)](https://travis-ci.org/apiology/quality)

# Quality -- code quality ratchet for Ruby

##Overview

Quality is a tool that runs quality checks on Ruby code using cane,
reek, flog, flay and rubocop and makes sure your numbers don't get any
worse over time.

```bash
$ gem install quality
```

and add it to your Rakefile like this:

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
Quality::Rake::Task.new { |t|
  # Name of quality task.
  # Defaults to :quality.
  t.quality_name = "quality"

  # Name of ratchet task.
  # Defaults to :ratchet.
  t.ratchet_name = "ratchet"

  # Array of strings describing tools to be skipped--e.g., ["cane"]
  #
  # Defaults to []
  t.skip_tools = []

  # Array of directory names which contain ruby files to analyze.
  #
  # Defaults to %w{app lib test spec feature}, which translates to *.rb in the base directory, as well as those directories.
  t.ruby_dirs = %w{app lib test spec feature}

  # Relative path to output directory where *_high_water_mark
  # files will be read/written
  #
  # Defaults to .
  t.output_dir = '.'
}
```

## Contributing

* Fork the repo
* Create a feature branch
* Submit a pull request

### Dependencies

Quality makes use of the following other gems, which do the actual checking:

* [reek](https://github.com/troessner/reek)
* [cane](https://github.com/square/cane)
* [flog](https://github.com/seattlerb/flog)
* [flay](https://github.com/seattlerb/flay)
* [rubocop](https://github.com/bbatsov/rubocop)

### Learn More

* Browse the code or install the latest development version from [https://github.com/apiology/quality/tree](https://github.com/apiology/quality/tree)
