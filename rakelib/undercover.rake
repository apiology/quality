# frozen_string_literal: true

desc 'Ensure PR changes are fully covered by tests'
task :undercover do |_t|
  ret =
    system('undercover --compare origin/main')
  raise unless ret
end
