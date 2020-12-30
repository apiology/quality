#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'test_helper.rb'

# Unit test the Config class
class TestConfig < MiniTest::Test
  # Just copy and paste this in from the README
  def readme_instructions(task)
    # Name of quality task.
    # Defaults to :quality.
    task.quality_name = 'quality'

    # Name of ratchet task.
    # Defaults to :ratchet.
    task.ratchet_name = 'ratchet'

    #
    # Set minimum values to ratchet to.
    #
    # Defaults to { bigfiles: 300 }
    #
    task.minimum_threshold = { rubocop: 300 }

    # Array of strings describing tools to be skipped--e.g., ["cane"]
    #
    # Defaults to []
    task.skip_tools = []

    # Log command executation
    #
    # Defaults to false
    task.verbose = false

    # Relative path to output directory where *_high_water_mark
    # files will be read/written
    #
    # Defaults to 'metrics'
    task.output_dir = 'metrics'

    # Pipe-separated regexp string describing what to look for in
    # files as 'todo'-like 'punchlist' comments.
    #
    # Defaults to 'XXX|TODO|FIXME|OPTIMIZE|HACK|REVIEW|LATER|FIXIT'
    task.punchlist_regexp = 'XXX|TODO|FIXME|OPTIMIZE|HACK|REVIEW|LATER|FIXIT'

    # Exclude the specified list of files--defaults to ['db/schema.rb']
    task.exclude_files = ['lib/whatever/imported_file.rb',
                          'lib/vendor/someone_else_fault.rb']

    # Alternately, express it as a glob:

    # Exclude the specified list of files
    task.source_files_exclude_glob =
      '{lib/whatever/imported_file.rb,lib/vendor/**/*.rb}'

    #
    # For configuration on classifying files as the correct language,
    # see https://github.com/github/linguist
    #
  end

  def test_quality_task_readme_instructions_still_work
    config = get_test_object do |_task|
      @mocks[:source_file_globber]
        .expects(:exclude_files=)
        .with(['lib/whatever/imported_file.rb',
               'lib/vendor/someone_else_fault.rb'])
    end
    readme_instructions(config)
  end

  def test_all_output_files
    config = get_test_object do
      @mocks[:dir]
        .expects(:glob)
        .with('metrics/*_high_water_mark')
        .returns(['metrics/a_high_water_mark'])
    end
    assert_equal(['metrics/a_high_water_mark'], config.all_output_files)
  end

  def test_source_files_exclude_glob_from_array
    config = get_test_object do
      @mocks[:source_file_globber]
        .expects(:exclude_files=)
        .with(%w[a b c])
      @mocks[:source_file_globber]
        .expects(:exclude_files)
        .returns(%w[a b c])
    end
    config.exclude_files = %w[a b c]
    assert_equal('{a,b,c}', config.source_files_exclude_glob)
  end

  def test_source_files_exclude_glob_from_glob
    config = get_test_object
    config.source_files_exclude_glob = '{d,e,f}'
    assert_equal('{d,e,f}', config.source_files_exclude_glob)
  end

  def get_test_object(&twiddle_mocks)
    @mocks = get_initializer_mocks(Quality::Config)
    yield @mocks unless twiddle_mocks.nil?
    Quality::Config.new(**@mocks)
  end
end
