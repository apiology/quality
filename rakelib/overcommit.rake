# frozen_string_literal: true

desc 'Run overcommit on current code'
task :overcommit do
  sh 'overcommit --run'
end
