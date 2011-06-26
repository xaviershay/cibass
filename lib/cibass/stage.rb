class Cibass

  # A build is composed of many stages. Currently only manual stages are
  # supported, so they must be succeeded or failed via the UI.
  #
  # Support for automatic stages is planned, where a build script will be
  # associated with the stage that will be automatically run when its dependencies
  # are met.
  class Stage < Struct.new(:event_bus, :id)
    attr_reader :state

    def initialize(*args)
      super
      @state = :not_started
    end

    def succeeded!
      transition_state(:succeeded)
    end

    def failed!
      transition_state(:failed)
    end

    private

    def transition_state(to)
      old = @state
      @state = to
      event_bus.push_event(:stage_stage_changed,
        stage: self,
        from: old,
        to:   @state
      )
    end

  end
end
