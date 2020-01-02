# frozen_string_literal: true

#
# Before this:
#  * Check if there's a newer RuboCop version.  If so:
#    * Bump major version of quality and change quality.gemspec to point to it:
#       https://github.com/rubocop-hq/rubocop/releases
#       https://github.com/apiology/quality/blob/master/quality.gemspec#L45
#    * bundle update
#    * bundle exec rubocop -a
#    * bundle exec rake quality # make fixes/bumps as needed
#  * Upgrade version of OpenJDK in Dockerfile
#  * Note last version here:
#       https://github.com/apiology/quality/releases
#  * Make sure version is bumped in lib/quality/version.rb
#  * Make a feature branch
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
#  * Merge PR
#  * git checkout master && git pull
#  * bundle update && bundle exec rake publish_all
desc 'Publish a release to RubyGems and hub.docker.com'
task publish_all: %i[localtest release wait_for_release publish_docker]
# After this:
#  * Verify Docker image sizes with "docker images" and update
#    DOCKER.md with new numbers
#  * Verify Travis is building
