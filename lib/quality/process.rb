# frozen_string_literal: true

require 'English'

module Quality
  # Wrapper around IO.popen that allows exit status to be mocked in tests.
  class Process
    def initialize(full_cmd,
                   dependencies = {})
      @full_cmd = full_cmd
      @popener = dependencies[:popener] || IO
    end

    def run
      @popener.popen(@full_cmd) do |file|
        yield file
      end
      $CHILD_STATUS&.exitstatus
    end
  end
end
