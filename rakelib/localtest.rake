# frozen_string_literal: true

desc 'Standard build when running on a workstation'
task localtest: %i[spec clear_metrics test feature undercover quality]
