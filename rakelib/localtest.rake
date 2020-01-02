# frozen_string_literal: true

desc 'Standard build when running on a workstation'
task localtest: %i[clear_metrics spec test feature quality]
