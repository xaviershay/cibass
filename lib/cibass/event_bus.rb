class Cibass

  # A generic event notification module that uses plain ruby hashes for
  # communication.
  module EventBus

    def add_listener(listener)
      listeners << listener
    end

    def remove_listener(listener)
      listeners.delete(listener)
    end

    def push_event(id, data)
      listeners.each do |x|
        x.handle_event(id, data)
      end
    end

    private

    def listeners
      @listeners ||= []
    end

  end

end
