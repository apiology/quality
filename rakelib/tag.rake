# frozen_string_literal: true

desc 'Tag that tests have succeeded at this point in CI, ' \
     'for future use in pronto'
task :tag do
  sh 'git tag -f tests_passed'
  sh 'git push -f origin tests_passed'
end
