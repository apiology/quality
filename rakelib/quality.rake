# frozen_string_literal: true

require 'quality/rake/task'

desc 'Verify and report on code quality issues'
task quality: %i[pronto update_bundle_audit]

Quality::Rake::Task.new do |t|
  t.exclude_files = ['etc/scalastyle_config.xml', 'ChangeLog.md', 'Dockerfile']
  t.minimum_threshold = { bigfiles: 300 }
  t.skip_tools = ['reek']
  # t.verbose = true
end
