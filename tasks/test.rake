# frozen_string_literal: true

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = FileList['test/unit/{,tool_tests/}test*.rb']
  # t.verbose = true
end
