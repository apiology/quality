# XXX: I should figure out how to use tagged releases in github.  Example:
# https://github.com/xsc/lein-ancient/issues/29
# https://github.com/xsc/lein-ancient/releases

require 'source_finder/source_file_globber'

module Quality
  # Configuration for running quality tool
  class Config
    attr_accessor :skip_tools, :verbose, :quality_name, :ratchet_name,
                  :output_dir, :punchlist_regexp

    extend Forwardable

    def_delegators(:source_file_globber,
                   :ruby_dirs=, :ruby_dirs,
                   :source_dirs=, :source_dirs,
                   :extra_files=, :extra_files,
                   :extra_ruby_files=, :extra_ruby_files,
                   :ruby_file_extensions=, :ruby_file_extensions,
                   :source_file_extensions=, :source_file_extensions,
                   :source_files_glob,
                   :ruby_files_glob,
                   :ruby_files)

    def source_file_globber
      @source_file_globber ||=
        SourceFinder::SourceFileGlobber.new(globber: @globber)
    end

    def all_output_files
      @globber.glob("#{output_dir}/*_high_water_mark")
    end

    def initialize(quality_name: 'quality',
                   ratchet_name: 'ratchet',
                   globber: fail)
      @quality_name = quality_name
      @ratchet_name = ratchet_name
      @skip_tools = []
      @output_dir = 'metrics'
      @verbose = false
      @globber = globber
    end
  end
end
