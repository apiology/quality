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

task after_test_success: %i[tag]

task :tag do
  sh 'git tag -f tests_passed'
  sh 'git push -f origin tests_passed'
end

task :pronto do
  sh 'pronto run -c origin/master --no-exit-code --unstaged || true'
  sh 'pronto run -c origin/master --no-exit-code --staged || true'
  sh 'pronto run -c origin/master --no-exit-code || true'
  sh 'git fetch --tags'
  sh 'pronto run -c tests_passed --no-exit-code || true'
end

task :update_bundle_audit do
  sh 'bundle-audit update'
end

task quality: %i[pronto update_bundle_audit]

Quality::Rake::Task.new do |t|
  t.exclude_files = ['etc/scalastyle_config.xml', 'ChangeLog.md', 'Dockerfile']
  t.minimum_threshold = { bigfiles: 300 }
  t.skip_tools = ['reek']
  # t.verbose = true
end

task :clear_metrics do |_t|
  puts Time.now
  ret = system('git checkout coverage/.last_run.json *_high_water_mark')
  raise unless ret
end

task localtest: %i[clear_metrics test quality]

task default: [:localtest]

task :wait_for_release do
  sleep 80
end

task :publish_docker do
  sh './publish-docker-image.sh'
end

#
# Before this:
#  * Check if there's a newer RuboCop version.  If so, bump major
#    version of quality and change quality.gemspec to point to it:
#       https://github.com/rubocop-hq/rubocop/releases
#       https://github.com/apiology/quality/blob/master/quality.gemspec#L51
#  * Note last version here:
#       https://github.com/apiology/quality/releases
#  * Make sure version is bumped in lib/quality/version.rb
#  * Run diff like this: git log vA.B.C...
#  * Check Changelog.md against actual checkins; add any missing content.
task publish_all: %i[localtest release wait_for_release publish_docker]
