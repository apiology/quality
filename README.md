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

