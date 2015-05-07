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
    # extensions--defaults to ['Rakefile']
    attr_accessor :extra_files

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
      @extra_files ||= ['Rakefile']
    end

    def source_files_glob(dirs = source_dirs,
                          extensions =
                          'rb,swift,cpp,c,java,py,clj,cljs,scala,js')
      File.join("{#{dirs.join(',')}}", '**',
                "{#{extra_files.join(',')},*.{#{extensions}}}")
    end

    def ruby_files_glob
      source_files_glob(ruby_dirs, 'rb')
    end

    def ruby_files
      @globber.glob('{*.rb,Rakefile}')
        .concat(@globber.glob(ruby_files_glob)).join(' ')
    end

    def initialize(quality_name: 'quality',
                   ratchet_name: 'ratchet',
                   globber: fail)
      @quality_name, @ratchet_name = quality_name, ratchet_name
      @skip_tools = []
      @output_dir = 'metrics'
      @verbose = false
      @globber = globber
    end
  end
end
