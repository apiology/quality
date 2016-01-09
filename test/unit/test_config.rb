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

    # Array of directory names which contain ruby files to analyze.
    #
    # Defaults to %w(app lib test spec feature), which translates to
    # *.rb in the base directory, as well as those directories.
    t.ruby_dirs = %w(app lib test spec feature)

    # Array of directory names which contain any type of source files to
    # analyze.
    #
    # Defaults to t.ruby_dirs
    t.source_dirs.concat(%w(MyProject MyProjectTests))

    # Pick any extra files that are source files, but may not have
    # extensions--defaults to %w(Rakefile Dockerfile)
    t.extra_source_files = ['tools/check-script', 'Rakefile']

    # Pick any extra files that are source files, but may not have
    # extensions--defaults to %w(Rakefile)
    t.extra_ruby_files = ['Rakefile']

    # Exclude the specified list of files--defaults to ['db/schema.rb']
    t.exclude_files = ['lib/whatever/imported_file.rb',
                       'lib/vendor/someone_else_fault.rb']

    # Alternately, express it as a glob:

    # Exclude the specified list of files
    t.source_files_exclude_glob =
      '{lib/whatever/imported_file.rb,lib/vendor/**/*.rb}'

    # Extensions for Ruby language files--defaults to 'rb,rake'
    t.ruby_file_extensions_arr = %w(rb rake)

    # Extensions for all source files--defaults to
    # 'rb,rake,swift,cpp,c,java,py,clj,cljs,scala,js,yml,sh,json'
    t.source_file_extensions_glob =
      'rb,rake,swift,cpp,c,java,py,clj,cljs,scala,js,yml,sh,json'

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
  end

  def check_interpreted_right(config)
    assert_equal('rb,rake', config.ruby_file_extensions_glob)
    assert_equal('{Rakefile,{*,.*}.{rb,rake},{app,lib,test,spec,feature}/**' \
                 '/{*,.*}.{rb,rake}}',
                 config.ruby_files_glob)
  end

  def test_quality_task_readme_instructions_still_work
    config = get_test_object do |_task|
    end
    readme_instructions(config)
    check_interpreted_right(config)
  end

  def get_test_object(&twiddle_mocks)
    @mocks = get_initializer_mocks(Quality::Config)
    yield @mocks unless twiddle_mocks.nil?
    Quality::Config.new(@mocks)
  end
end
