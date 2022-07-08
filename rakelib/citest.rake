# frozen_string_literal: true

desc 'Run tasks to be done during a continuous integration (CI) build'
task citest: %i[clear_metrics spec feature undercover]
