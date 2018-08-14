# Configuration

To add configuration for the qulaity gem, you can add configuration to
your `Rakefile` (if using the Gem directly), or `Rakefile.quality` if
you're using the quality gem via Docker:

```ruby
Quality::Rake::Task.new do |t|
  # Name of quality task.
  # Defaults to :quality.
  t.quality_name = 'quality'

  # Name of ratchet task.
  # Defaults to :ratchet.
  t.ratchet_name = 'ratchet'

  #
  # Set minimum values to ratchet to.
  #
  # Defaults to { bigfiles: 300 }
  #
  t.minimum_threshold = { bigfiles: 300 }

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
  # Defaults to 'XXX|TODO|FIXME|OPTIMIZE|HACK|REVIEW|LATER|FIXIT'
  t.punchlist_regexp = 'XXX|TODO|FIXME|OPTIMIZE|HACK|REVIEW|LATER|FIXIT'

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
