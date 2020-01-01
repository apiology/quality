# frozen_string_literal: true

desc 'Push up a new Docker image to hub.docker.com'
task :publish_docker do
  sh './publish-docker-image.sh'
end
