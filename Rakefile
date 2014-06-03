require 'rake/clean'
require "bundler/gem_tasks"
require 'quality/rake/task'

$:.unshift File.dirname(__FILE__) + '/lib'

PROJECT_NAME = 'quality'

BUILD_DIR = 'build'; directory BUILD_DIR
PKG_DIR = "#{BUILD_DIR}/pkg"; directory PKG_DIR

GEM_MANIFEST = "Manifest.txt"
VERSION_FILE = 'lib/quality.rb'

CLOBBER.include("#{BUILD_DIR}/*")

Dir['tasks/**/*.rake'].each { |t| load t }

Quality::Rake::Task.new do |t|
  t.skip_tools = ['reek']
end

task :clear_metrics do |t|
  puts Time.now
  ret =
    system("git checkout coverage/.last_run.json *_high_water_mark")
  if !ret
    fail
  end
end

task :localtest => [:clear_metrics, :test, :quality]

task :default => [:localtest]
