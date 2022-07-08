# frozen_string_literal: true

desc 'Ensure that any locally ratcheted coverage metrics are cleared back ' \
     'to git baseline'
task :clear_metrics do |_t|
  ret =
    system('git checkout coverage/.last_run.json')
  raise unless ret

  # Without this old lines which are removed are still counted,
  # leading to inconsistent coverage percentages between runs.
  #
  # need to save coverage/.last_run.json
  ret =
    system('rm -fr coverage/assets coverage/.*.json.lock coverage/lcov/* coverage/index.html coverage/.resultset.json')
  raise unless ret
end
