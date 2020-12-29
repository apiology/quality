# frozen_string_literal: true

# this 'time' require statement is needed as of active_support, which
# tries to remap the xmlschema method.  Turns out there are two 'Time'
# classes - methods get added when you "require 'time'".
#
# https://github.com/rails/rails/pull/40859
#
# https://app.circleci.com/pipelines/github/apiology/checkoff/46/workflows/27702e5f-ce86-4960-8b5e-f5277ddf159e/jobs/124
require 'time'
require 'active_support'
require 'active_support/core_ext'

# Represents a source directory full of classe - e.g.,
# lib/vincelifedaily/checks/*
class DirectoryOfClasses
  attr_reader :dir, :module_name

  def initialize(dir: raise, class_suffix: '', module_name: '')
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
