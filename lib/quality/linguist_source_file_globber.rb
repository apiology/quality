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

    def all_files
      @source_files ||= begin
        tree = @commit.target.tree
        tree.flat_map do |file|
          if file[:type] == :blob
            [file[:name]]
          else
            []
          end
        end
      end
    end

    def ruby_files
      @breakdown_by_file['Ruby'] || []
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
          yield blob
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
        real_files_matching do |blob|
          blob.documentation? || !blob.language.nil?
        end
      end
    end
  end
end
