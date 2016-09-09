# XXX: I should figure out how to use tagged releases in github.  Example:
# https://github.com/xsc/lein-ancient/issues/29
# https://github.com/xsc/lein-ancient/releases

require_relative 'linguist_source_file_globber'

module Quality
  # Configuration for running quality tool
  class Config
    attr_accessor :skip_tools, :verbose, :quality_name, :ratchet_name,
                  :output_dir, :punchlist_regexp, :exclude_files,
                  :source_files_exclude_glob

    extend Forwardable

    def_delegators(:source_file_globber, :ruby_files, :js_files)

    def source_files_glob
      to_glob(source_files)
    end

    def source_files_exclude_glob
      to_glob(exclude_files)
    end

    def all_output_files
      @globber.glob("#{output_dir}/*_high_water_mark")
    end

    def initialize(quality_name: 'quality',
                   ratchet_name: 'ratchet',
                   source_file_globber: Quality::LinguistSourceFileGlobber.new)
      @quality_name = quality_name
      @ratchet_name = ratchet_name
      @skip_tools = []
      @output_dir = 'metrics'
      @verbose = false
      @source_file_globber = source_file_globber
    end
  end
end
