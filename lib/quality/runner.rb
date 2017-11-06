# frozen_string_literal: true

require 'active_support/inflector'
require 'forwardable'
require_relative 'which'
require_relative 'directory_of_classes'

# Quality is a tool that runs quality checks on Ruby code using cane,
# reek, flog, flay and rubocop and makes sure your numbers don't get
# any worse over time.
module Quality
  current_dir = File.dirname(File.expand_path(__FILE__))
  TOOL_CLASSES = DirectoryOfClasses.new(dir: "#{current_dir}/tools",
                                        module_name: 'Quality::Tools')
  ALL_TOOLS = TOOL_CLASSES.basenames_without_extension
  TOOL_CLASSES.require_classes

  # Knows how to run different quality tools based on a configuration
  # already determined.
  class Runner
    TOOL_CLASSES.symbols_and_classes.each_value { |clazz| include clazz }

    extend ::Forwardable

    def initialize(config, gem_spec: Gem::Specification,
                   quality_checker_class: Quality::QualityChecker,
                   count_io: IO, count_file: File,
                   globber: Dir, which: Which.new)
      @config = config
      @gem_spec = gem_spec
      @quality_checker_class = quality_checker_class
      @count_io = count_io
      @count_file = count_file
      @globber = globber
      @which = which
    end

    def run_quality
      tools.each do |tool_name, tool_exe|
        run_quality_with_tool(tool_name, tool_exe)
      end
    end

    def run_quality_with_tool(tool_name, tool_exe)
      suppressed = @config.skip_tools.include? tool_name
      installed = @gem_spec.find_all_by_name(tool_name).any? ||
                  !@which.which(tool_exe).nil?

      if installed && !suppressed
        method("quality_#{tool_name}".to_sym).call
      elsif !installed
        puts "#{tool_name} not installed"
      end
    end

    def run_ratchet
      @config.all_output_files.each { |filename| run_ratchet_on_file(filename) }
    end

    def run_ratchet_on_file(filename)
      puts "Processing #{filename}"
      existing_violations = count_existing_violations(filename)
      new_violations = [0, existing_violations - 1].max
      write_violations(filename, new_violations)
    end

    def write_violations(filename, new_violations)
      @count_file.open(filename, 'w') do |file|
        file.write(new_violations.to_s + "\n")
      end
    end

    def count_existing_violations(filename)
      existing_violations = @count_io.read(filename).to_i
      raise("Problem with file #{filename}") if existing_violations < 0
      existing_violations
    end

    def command_name(ancestor, name)
      if ancestor.respond_to? :command_name
        ancestor.command_name
      else
        name
      end
    end

    def tools
      self.class.ancestors.map do |ancestor|
        ancestor_name = ancestor.to_s
        next unless ancestor_name.start_with?('Quality::Tools::')
        name = ancestor.to_s.split('::').last.underscore
        [name, command_name(ancestor, name)]
      end.compact
    end

    def minimum_threshold_for(cmd)
      @config.minimum_threshold[cmd.to_sym] || 0
    end

    def ratchet_quality_cmd(cmd,
                            command_options,
                            &count_violations_on_line)
      quality_checker = @quality_checker_class.new(cmd,
                                                   command_options,
                                                   @config.output_dir,
                                                   @config.verbose,
                                                   minimum_threshold_for(cmd))
      quality_checker.execute(&count_violations_on_line)
    end

    def_delegators :@config,
                   :ruby_files,
                   :scala_files,
                   :python_files,
                   :markdown_files,
                   :shell_files,
                   :source_files,
                   :source_files_glob,
                   :source_and_doc_files,
                   :source_and_doc_files_glob,
                   :exclude_files,
                   :source_files_exclude_glob,
                   :punchlist_regexp,
                   :scalastyle_config,
                   :scalastyle_exclude,
                   :js_files
  end
end
