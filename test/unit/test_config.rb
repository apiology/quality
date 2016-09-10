#!/usr/bin/env ruby

require_relative 'test_helper.rb'

# Unit test the Config class
class TestConfig < MiniTest::Test
  # Just copy and paste this in from the README
  def readme_instructions(t)
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

  def test_quality_task_readme_instructions_still_work
    config = get_test_object do |_task|
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
    config = get_test_object
    config.exclude_files = %w(a b c)
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
    Quality::Config.new(@mocks)
  end
end
