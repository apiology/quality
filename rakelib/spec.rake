# frozen_string_literal: true

begin
  require 'rspec/core/rake_task'

  desc 'Run specs'
  RSpec::Core::RakeTask.new(:spec) do |task|
    task.pattern = 'spec/**/*_spec.rb'
    task.rspec_opts = '--format doc --require spec_helper'
  end
rescue LoadError
  true
end
