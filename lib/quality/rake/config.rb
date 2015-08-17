# XXX: I should figure out how to use tagged releases in github.  Example:
# https://github.com/xsc/lein-ancient/issues/29
# https://github.com/xsc/lein-ancient/releases

# XXX: This should be moved out of rake directory
module Quality
  # Configuration for running quality tool
  class Config
    # See README.md for documentation on these configuration parameters.

    attr_accessor :quality_name, :ratchet_name, :skip_tools, :verbose,
                  :ruby_dirs, :source_dirs, :extra_files, :extra_ruby_files,
                  :ruby_file_extensions, :source_file_extensions,
                  :punchlist_regexp, :output_dir

    def ruby_dirs
      @ruby_dirs ||= %w(src app lib test spec feature)
    end

    def source_dirs
      @source_dirs ||= ruby_dirs.clone
    end

    def extra_files
      @extra_files ||= extra_ruby_files.clone.concat(%w(Dockerfile))
    end

    def extra_ruby_files
      @extra_ruby_files ||= %w(Rakefile)
    end

    def source_file_extensions
      @source_file_extensions ||=
        "#{ruby_file_extensions},swift,cpp,c,java,py,clj,cljs,scala,js," \
        'yml,sh,json'
    end

    def source_files_glob(extra_source_files = extra_files,
                          dirs = source_dirs,
                          extensions = source_file_extensions)
      "{#{extra_source_files.join(',')}," \
        "{*,.*}.{#{extensions}}," +
        File.join("{#{dirs.join(',')}}",
                  '**',
                  "{*,.*}.{#{extensions}}") +
        '}'
    end

    def ruby_file_extensions
      @ruby_file_extensions ||= 'rb,rake,gemspec'
    end

    def ruby_files_glob
      source_files_glob(extra_ruby_files, ruby_dirs, ruby_file_extensions)
    end

    def ruby_files
      @globber.glob(ruby_files_glob).join(' ')
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
