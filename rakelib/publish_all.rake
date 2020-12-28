# frozen_string_literal: true

desc 'Publish a release to RubyGems and hub.docker.com'
task publish_all: %i[localtest release wait_for_release publish_docker]
