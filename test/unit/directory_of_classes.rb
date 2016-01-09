require 'active_support'
require 'active_support/core_ext'

# Represents a source directory full of classe - e.g.,
# lib/vincelifedaily/checks/*
class DirectoryOfClasses
  attr_reader :dir, :module_name

  def initialize(dir: fail, class_suffix: '', module_name: '')
    @dir = dir
    @class_suffix = class_suffix
    @module_name = module_name
  end

  def filenames
    Dir.glob("#{dir}/**.rb").sort
  end

  def basenames
    filenames.map { |filename| File.basename(filename) }
  end

  def basenames_without_extension
    filenames.map { |filename| File.basename(filename, '.*') }
  end

  def require_classes
    basenames.each do |basename|
      path = "#{dir}/#{basename}"
      require_relative path
    end
  end

  def include_classes
  end

  def class_by_name
    @class_by_name ||= Hash[symbols_and_classes]
  end

  def symbols_and_classes
    @symbols_and_classes ||= filenames.map do |filename|
      basename = File.basename(filename, '.rb')

      class_name = "#{module_name}::#{basename.camelize}#{@class_suffix}"
      clazz = class_name.constantize
      symbol = basename.to_sym
      [symbol, clazz]
    end
  end
end
