# frozen_string_literal: true

require 'open3'
require 'quality'

# Add the bin directory, to allow testing of gem executables as if the gem is
# already installed.
root_dir = RSpec::Core::RubyProject.root
exec_dir = File.join(File::SEPARATOR, root_dir, 'bin')
ENV['PATH'] = [exec_dir, ENV['PATH']].join(File::PATH_SEPARATOR)

# Courtesy of:
# https://raw.github.com/cupakromer/tao-of-tdd/master/adder/spec/support/
#    capture_exec.rb
def exec_io(*cmd)
  cmd = cmd.flatten
  out_err, _exit_code = Open3.capture2e(*cmd)

  out_err
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.order = 'random'
  config.alias_it_should_behave_like_to :has_behavior
  config.alias_it_should_behave_like_to :it_has_behavior, 'has behavior:'
end

def let_double(*doubles)
  doubles.each do |double_sym|
    let(double_sym) { double(double_sym.to_s) }
  end
end
