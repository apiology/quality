# frozen_string_literal: true

desc 'Ensure that any locally ratcheted coverage metrics are cleared back ' \
     'to git baseline'
task :clear_metrics do |_t|
  # Without this old lines which are removed are still counted,
  # leading to inconsistent coverage percentages between runs.
  raise unless system('rm -fr coverage/')
end
