require 'forwardable'
require_relative 'tools/cane'
require_relative 'tools/flay'
require_relative 'tools/flog'
require_relative 'tools/reek'
require_relative 'tools/rubocop'
require_relative 'tools/bigfiles'
require_relative 'tools/punchlist'

# XXX: This name is too similar to process_runner

module Quality
  # Knows how to run different quality tools based on a configuration
  # already determined.
  class Runner
    include Tools::Cane
    include Tools::Flay
    include Tools::Flog
    include Tools::Reek
    include Tools::Rubocop
    include Tools::BigFiles
    include Tools::Punchlist

    extend ::Forwardable

    def initialize(config,
                   gem_spec: Gem::Specification,
                   quality_checker_class: Quality::QualityChecker,
                   count_io: IO,
                   count_file: File,
                   globber: Dir)
      @config = config
      @gem_spec = gem_spec
      @quality_checker_class = quality_checker_class
      @count_io = count_io
      @count_file = count_file
      @globber = globber
    end

    def run_quality
      tools.each { |tool| run_quality_with_tool(tool) }
    end

    def run_quality_with_tool(tool)
      installed = @gem_spec.find_all_by_name(tool).any?
      suppressed = @config.skip_tools.include? tool

      if installed && !suppressed
        method("quality_#{tool}".to_sym).call
      elsif !installed
        puts "#{tool} not installed"
      end
    end

    def run_ratchet
      @config.all_output_files.each do |filename|
        run_ratchet_on_file(filename)
      end
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
      fail("Problem with file #{filename}") if existing_violations < 0
      existing_violations
    end

    def tools
      self.class.ancestors.map do |ancestor|
        ancestor_name = ancestor.to_s
        next unless ancestor_name.start_with?('Quality::Tools::')
        ancestor_name.split('::').last.downcase
      end.compact
    end

    def ratchet_quality_cmd(cmd,
                            command_options,
                            &count_violations_on_line)
      quality_checker = @quality_checker_class.new(cmd,
                                                   command_options,
                                                   @config.output_dir,
                                                   @config.verbose)
      quality_checker.execute(&count_violations_on_line)
    end

    def_delegators :@config, :ruby_files, :ruby_files_glob, :source_files_glob,
                   :punchlist_regexp
  end
end
