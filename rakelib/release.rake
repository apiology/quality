# frozen_string_literal: true

require 'bundler/gem_tasks'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

PROJECT_NAME = 'quality'

BUILD_DIR = 'build'
directory BUILD_DIR

PKG_DIR = "#{BUILD_DIR}/pkg"
directory PKG_DIR

GEM_MANIFEST = 'Manifest.txt'
VERSION_FILE = 'lib/quality.rb'

CLOBBER.include("#{BUILD_DIR}/*")

desc 'Release to RubyGems'
task release: [:prerelease]
