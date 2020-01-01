# frozen_string_literal: true

desc 'Placeholder for anything to be done before prepping a release'
task :prerelease do
  sh 'git fetch --tags --force'
end
