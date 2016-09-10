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
                   pwd: Dir.pwd)
      @repo = repo
      @commit = commit
      @project = project
      @breakdown_by_file = @project.breakdown_by_file
      @file_blob = file_blob
      @pwd = pwd
    end

    def submodule_or_symlink?(file)
      # Skip submodules and symlinks
      mode = file[:filemode]
      mode_format = (mode & 0170000)
      mode_format == 0120000 ||
        mode_format == 040000 ||
        mode_format == 0160000
    end

    def all_files
      @source_files ||= begin
        files = []
        tree = @commit.target.tree
        tree.walk(:preorder) do |root, file|
          unless file[:type] != :blob || submodule_or_symlink?(file)
            files << "#{root}#{file[:name]}"
          end
        end
        files
      end
    end

    def ruby_files
      # Linguist treats Gemfile.lock as Ruby code.
      #
      # https://github.com/github/linguist/issues/1740
      @breakdown_by_file['Ruby'] - ['Gemfile.lock'] || []
    end

    def python_files
      @breakdown_by_file['Python'] || []
    end

    def js_files
      @breakdown_by_file['JavaScript'] || []
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
          !blob.language.nil?
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
  end
end
