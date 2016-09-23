# frozen_string_literal: true
require 'rugged'
require 'linguist'

module Quality
  # Uses the Linguist gem to find and classify source files.
  #
  # Note: Requires files to be commited within a git repo.
  class LinguistSourceFileGlobber
    def initialize(repo: Rugged::Repository.new('.'),
                   commit: repo.head,
                   project: Linguist::Repository.new(repo, commit.target_id),
                   file_blob: Linguist::FileBlob,
                   file_class: File,
                   pwd: Dir.pwd)
      @repo = repo
      @commit = commit
      @project = project
      @breakdown_by_file = @project.breakdown_by_file
      @file_blob = file_blob
      @file_class = file_class
      @exclude_files = nil
      @pwd = pwd
    end

    attr_writer :exclude_files

    def submodule_or_symlink?(file)
      # Skip submodules and symlinks
      mode = file[:filemode]
      mode_format = (mode & 0o0170000)
      mode_format == 0o0120000 ||
        mode_format == 0o040000 ||
        mode_format == 0o0160000
    end

    def ok_to_process?(filename, file)
      file[:type] == :blob &&
        !submodule_or_symlink?(file) &&
        @file_class.exist?(filename) &&
        !@file_class.symlink?(filename) &&
        @file_class.readable?(filename)
    end

    def all_files
      @all_files ||= begin
        files = []
        tree = @commit.target.tree
        tree.walk(:preorder) do |root, file|
          filename = "#{root}#{file[:name]}"
          files << filename if ok_to_process?(filename, file)
        end
        files
      end
    end

    def language_files(language)
      (@breakdown_by_file[language] || []) - exclude_files
    end

    def ruby_files
      # Linguist treats Gemfile.lock as Ruby code.
      #
      # https://github.com/github/linguist/issues/1740
      language_files('Ruby') - ['Gemfile.lock']
    end

    def python_files
      language_files('Python')
    end

    def shell_files
      language_files('Shell')
    end

    def js_files
      language_files('JavaScript')
    end

    def exclude_files
      @exclude_files || []
    end

    def real_files_matching
      all_files.select do |filename|
        blob = @file_blob.new(filename, @pwd)
        if blob.generated? || blob.vendored?
          false
        else
          yield blob, filename
        end
      end
    end

    def source_files
      @source_files ||= begin
        real_files_matching do |blob|
          !blob.language.nil? && !blob.documentation?
        end
      end
    end

    def source_and_doc_files
      @source_and_doc_files ||= begin
        real_files_matching do |blob, _filename|
          if blob.documentation? || !blob.language.nil?
            true
          else
            # puts "Excluding #{filename} from source_and_doc_files"
            false
          end
        end
      end
    end

    def real_files_of_type(file_type)
      real_files_matching do |blob, _filename|
        blob.language.to_s == file_type
      end
    end

    def markdown_files
      @markdown_files ||= real_files_of_type('Markdown')
    end
  end
end
