# frozen_string_literal: true

desc 'Look for incremental quality issues'
task :pronto do
  formatter = '-f github_pr' if ENV.key? 'PRONTO_GITHUB_ACCESS_TOKEN'
  if ENV.key? 'TRAVIS_PULL_REQUEST'
    ENV['PRONTO_PULL_REQUEST_ID'] = ENV['TRAVIS_PULL_REQUEST']
  elsif ENV.key? 'CIRCLE_PULL_REQUEST'
    ENV['PRONTO_PULL_REQUEST_ID'] = ENV['CIRCLE_PULL_REQUEST'].split('/').last
  end
  sh "bundle exec " \
     "pronto run #{formatter} -c origin/main --no-exit-code --unstaged " \
     "|| true"
  sh "bundle exec " \
     "pronto run #{formatter} -c origin/main --no-exit-code --staged || true"
  sh "bundle exec " \
     "pronto run #{formatter} -c origin/main --no-exit-code || true"
  sh 'git fetch --tags --force'
  sh "bundle exec " \
     "pronto run #{formatter} -c tests_passed --no-exit-code || true"
end
