# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

desc 'Update definitions used in bundle-audit'
task :update_bundle_audit do
  sh 'echo $PATH' # TODO
  sh 'env' # TODO
  sh 'bundle check' # TODO
  sh 'bundle exec bundle-audit update'
end
