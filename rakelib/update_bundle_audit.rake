# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

desc 'Update definitions used in bundle-audit'
task :update_bundle_audit do
  sh 'bundle exec bundle-audit update'
end
