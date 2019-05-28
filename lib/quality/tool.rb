# frozen_string_literal: true

module Quality
  module Tools
    # represents a code quality tool which can be run on source files
    class Tool
      extend ::Forwardable

      def initialize(runner)
        @runner = runner
      end

      def_delegators(:@runner,
                     :source_and_doc_files_glob,
                     :source_files_exclude_glob,
                     :ratchet_quality_cmd,
                     :js_files,
                     :python_files,
                     :ruby_files,
                     :exclude_files,
                     :markdown_files,
                     :punchlist_regexp,
                     :scalastyle_config,
                     :scalastyle_exclude,
                     :scala_files,
                     :shell_files)
    end
  end
end
