# frozen_string_literal: true

desc 'Rebaseline quality thresholds to last commit'
task :clear_metrics do |_t|
  puts Time.now
  ret = system('git checkout coverage/.last_run.json *_high_water_mark')
  raise unless ret
end
