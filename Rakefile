# frozen_string_literal: true

require 'rake/clean'
require 'bundler/gem_tasks'
require 'quality/rake/task'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'

PROJECT_NAME = 'quality'

BUILD_DIR = 'build'
directory BUILD_DIR

PKG_DIR = "#{BUILD_DIR}/pkg"
directory PKG_DIR

GEM_MANIFEST = 'Manifest.txt'
VERSION_FILE = 'lib/quality.rb'

CLOBBER.include("#{BUILD_DIR}/*")

Dir['tasks/**/*.rake'].each { |t| load t }

task after_test_success: %i[tag]

task :tag do
  sh 'git tag -f tests_passed'
  sh 'git push -f origin tests_passed'
end

task :pronto do
  formatter = '-f github' if ENV.key? 'PRONTO_GITHUB_ACCESS_TOKEN'
  sh "pronto run #{formatter} -c origin/master --no-exit-code --unstaged "\
     "|| true"
  sh "pronto run #{formatter} -c origin/master --no-exit-code --staged || true"
  sh "pronto run #{formatter} -c origin/master --no-exit-code || true"
  sh 'git fetch --tags'
  sh "pronto run #{formatter} -c tests_passed --no-exit-code || true"
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
#  * Upgrade version of OpenJDK in Dockerfile
#  * Note last version here:
#       https://github.com/apiology/quality/releases
#  * Make sure version is bumped in lib/quality/version.rb
#  * Check in changes
#  * Run diff like this: git log vA.B.C...
#  * Check Changelog.md against actual checkins; add any missing content.
#  * Update .travis.yml with latest supported ruby Versions:
#    https://www.ruby-lang.org/en/downloads/releases/
#  * Drop any Ruby versions that are eol:
#    https://www.ruby-lang.org/en/downloads/branches/
#  * Update .rubocop.yml#AllCops.TargetRubyVersion to the earliest supported
#    version
#  * Check in any final changes
#  * bundle update && bundle exec rake publish_all
task publish_all: %i[localtest release wait_for_release publish_docker]
# After this:
#  * Verify Docker image sizes with "docker images" and update
#    DOCKER.md with new numbers
#  * Verify Travis is building
