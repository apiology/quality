# frozen_string_literal: true

desc 'Update definitions used in bundle-audit'
task :update_bundle_audit do
  sh 'bundle-audit update'
end
