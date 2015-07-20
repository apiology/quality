# XXX: I should figure out how to use tagged releases in github.  Example:
# https://github.com/xsc/lein-ancient/issues/29
# https://github.com/xsc/lein-ancient/releases

# XXX: This should be moved out of rake directory
module Quality
  # Configuration for running quality tool
  class Config
    # Name of quality task.
    # Defaults to :quality.
    attr_accessor :quality_name

    # Name of ratchet task.
    # Defaults to :ratchet.
    attr_accessor :ratchet_name

    # Array of strings describing tools to be skipped--e.g., ["cane"]
    #
    # Defaults to []
    attr_accessor :skip_tools

    # Log command executation
    #
    # Defaults to false
    attr_accessor :verbose

    # Array of directory names which contain ruby files to analyze.
    #
    # Defaults to %w(app lib test spec feature), which translates to *.rb in
    # the base directory, as well as those directories.
    attr_writer :ruby_dirs

    # Array of directory names which contain any type of source
    # files to analyze.
    #
    # Defaults to the same as ruby_dirs
    attr_writer :source_dirs

    # Pick any extra files that are source files, but may not have
    # extensions--defaults to %w(Rakefile Dockerfile)
    attr_accessor :extra_files

    # Extensions for Ruby language files--defaults to 'rb,rake'
    attr_accessor :ruby_file_extensions

    # Extensions for all source files--defaults to
    # 'rb,rake,swift,cpp,c,java,py,clj,cljs,scala,js,yml,sh,json'
    attr_accessor :source_file_extensions

    # Pipe-separated regexp string describing what to look for in
    # files as 'todo'-like 'punchlist' comments.
    #
    # Defaults to 'XXX|TODO'
    attr_accessor :punchlist_regexp

    # Relative path to output directory where *_high_water_mark
    # files will be read/written
    #
    # Defaults to .
    attr_accessor :output_dir

    def ruby_dirs
      @ruby_dirs ||= %w(src app lib test spec feature)
    end

    def source_dirs
      @source_dirs ||= ruby_dirs.clone
    end

    def extra_files
      @extra_files ||= %w(Rakefile Dockerfile)
    end

    def source_file_extensions
      @source_file_extensions ||=
        "#{ruby_file_extensions},swift,cpp,c,java,py,clj,cljs,scala,js," \
        'yml,sh,json'
    end

    def source_files_glob(dirs = source_dirs,
                          extensions = source_file_extensions)
      "{#{extra_files.join(',')}," +
        File.join("{#{dirs.join(',')}}",
                  '**',
                  "*.{#{extensions}}") +
        '}'
    end

    def ruby_file_extensions
      @ruby_file_extensions ||= 'rb,rake'
    end

    def ruby_files_glob
      source_files_glob(ruby_dirs, ruby_file_extensions)
    end

    def ruby_files
      @globber.glob("{*.{#{ruby_file_extensions}},Rakefile}")
        .concat(@globber.glob(ruby_files_glob)).join(' ')
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
