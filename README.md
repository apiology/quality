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

