# Quality -- code quality ratchet for Ruby

##Overview

Quality is a tool that runs quality checks on Ruby code using cane,
reek, flog and flay, and makes sure your numbers don't get any worse
over time.

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
  # Defaults to %w{lib test features}, which translates to *.rb in the base directory, as well as lib, test, and features.
  t.ruby_dirs = %w{lib test features}

  # Relative path to output directory where *_high_water_mark
  # files will be read/written
  #
  # Defaults to .
  t.output_dir = '.'
}
```


## Optional tools

The 'reek' gem is supported, but not by default.  To support it, add the 'reek' gem to your Gemspec.  Once reek supports Ruby 2.0, it will presumably support newer versions of the 'ruby_parser' gem.  Currently it will disable Ruby 2.0 supports in other quality-check gems by forcing them to a lower version.

https://github.com/troessner/reek/issues/165

## Contributing

* Fork the repo
* Create a feature branch
* Submit a pull request

### Dependencies

Quality makes use of the following other gems, which do the actual checking:

* reek
* cane
* flog
* flay

### Learn More

* Browse the code or install the latest development version from [https://github.com/apiology/quality/tree](https://github.com/apiology/quality/tree)

