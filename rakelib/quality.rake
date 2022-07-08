# frozen_string_literal: true

require 'quality/rake/task'

Quality::Rake::Task.new do |task|
  task.exclude_files = [
    'etc/scalastyle_config.xml', 'ChangeLog.md', 'Dockerfile', 'Gemfile.lock'
  ]
  # cane deprecated in favor of rubocop, reek rarely actionable
  task.skip_tools = %w[reek cane]
  task.output_dir = 'metrics'
  task.punchlist_regexp = 'XX' \
                          'X|TOD' \
                          'O|FIXM' \
                          'E|OPTIMIZ' \
                          'E|HAC' \
                          'K|REVIE' \
                          'W|LATE' \
                          'R|FIXI' \
                          'T|xi' \
                          't '
  # task.verbose = true
end

desc 'Verify and report on code quality issues'
task quality: %i[pronto update_bundle_audit overcommit]
