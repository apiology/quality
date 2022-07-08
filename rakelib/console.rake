# frozen_string_literal: true

desc 'Load up quality in pry'
task :console do |_t|
  exec 'pry -I lib -r quality'
end
