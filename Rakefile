# frozen_string_literal: true
require 'rake/clean'
require 'bundler/gem_tasks'
require 'quality/rake/task'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'

PROJECT_NAME = 'quality'.freeze

BUILD_DIR = 'build'.freeze
directory BUILD_DIR

PKG_DIR = "#{BUILD_DIR}/pkg".freeze
directory PKG_DIR

GEM_MANIFEST = 'Manifest.txt'.freeze
VERSION_FILE = 'lib/quality.rb'.freeze

CLOBBER.include("#{BUILD_DIR}/*")

Dir['tasks/**/*.rake'].each { |t| load t }

Quality::Rake::Task.new do |t|
  t.exclude_files = ['etc/scalastyle_config.xml', 'ChangeLog.md']
  t.minimum_threshold = { rubocop: 500 }
  t.skip_tools = ['reek']
  t.verbose = true
end

task :clear_metrics do |_t|
  puts Time.now
  ret = system('git checkout coverage/.last_run.json *_high_water_mark')
  raise unless ret
end

task localtest: [:clear_metrics, :test, :quality]

task default: [:localtest]

task :wait_for_release do
  sleep 80
end

task :publish_docker do
  sh './publish-docker-image.sh'
end

task publish_all: [:localtest, :release, :wait_for_release, :publish_docker]
