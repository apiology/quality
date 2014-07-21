require 'English'

class ProcessRunner
  def initialize(full_cmd,
                 popener: IO)
    @full_cmd = full_cmd
    @popener = popener
  end

  def run(&block)
    command_output = nil
    @popener.popen(@full_cmd) do |file|
      yield file
    end
    $CHILD_STATUS.exitstatus
  end
end
