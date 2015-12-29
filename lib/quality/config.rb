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
                   :ruby_dirs_arr=, :ruby_dirs_arr,
                   :extra_ruby_files_arr=, :extra_ruby_files_arr,
                   :ruby_file_extensions_arr=, :ruby_file_extensions_arr,
                   :ruby_file_extensions_glob=, :ruby_file_extensions_glob,
                   :ruby_files_glob, :ruby_files_arr)

    def_delegators(:source_file_globber,
                   :js_dirs_arr=, :js_dirs_arr,
                   :extra_js_files_arr=, :extra_js_files_arr,
                   :js_file_extensions_arr=, :js_file_extensions_arr,
                   :js_file_extensions_glob=, :js_file_extensions_glob,
                   :js_files_glob, :js_files_arr)

    def_delegators(:source_file_globber,
                   :python_files_glob, :python_files_arr)

    def_delegators(:source_file_globber,
                   :source_dirs_arr=, :source_dirs_arr,
                   :extra_source_files_arr=, :extra_source_files_arr,
                   :exclude_files_arr=, :exclude_files_arr,
                   :source_file_extensions_arr=, :source_file_extensions_arr,
                   :source_file_extensions_glob=, :source_file_extensions_glob,
                   :source_and_doc_files_glob,
                   :source_files_glob,
                   :source_files_exclude_glob,
                   :source_files_exclude_glob=)

    alias_method(:extra_ruby_files, :extra_ruby_files_arr)
    alias_method(:extra_ruby_files=, :extra_ruby_files_arr=)
    alias_method(:ruby_files, :ruby_files_arr)
    alias_method(:python_files, :python_files_arr)
    alias_method(:ruby_dirs, :ruby_dirs_arr)
    alias_method(:ruby_dirs=, :ruby_dirs_arr=)
    alias_method(:ruby_file_extensions, :ruby_file_extensions_glob)
    alias_method(:ruby_file_extensions=, :ruby_file_extensions_glob=)

    alias_method(:extra_files, :extra_source_files_arr)
    alias_method(:extra_files=, :extra_source_files_arr=)
    alias_method(:extra_source_files, :extra_source_files_arr)
    alias_method(:extra_source_files=, :extra_source_files_arr=)
    alias_method(:source_dirs, :source_dirs_arr)
    alias_method(:source_dirs=, :source_dirs_arr=)
    alias_method(:exclude_files, :exclude_files_arr)
    alias_method(:exclude_files=, :exclude_files_arr=)

    # This was named and documented poorly early on
    alias_method(:source_file_extensions, :source_file_extensions_glob)
    alias_method(:source_file_extensions=, :source_file_extensions_glob=)

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
      source_file_globber.source_files_exclude_glob =
        '{' + source_file_globber.source_files_exclude_glob +
        ',db/schema.rb' \
        '}'
    end
  end
end
