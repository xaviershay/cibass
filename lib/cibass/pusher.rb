require 'rack/websocket'
require 'json'

class Cibass
  
  # A websockets server to push out event notifications to clients. Currently
  # there are no fine grained events. A full snapshot of the system is resent
  # on every change.
  class Pusher < Rack::WebSocket::Application

    def initialize(instance)
      @instance = instance
      super()
    end

    def on_open(env)
      send_data full_json_hash
      @instance.add_listener(self)
    end

    def on_close(env)
      @instance.remove_listener(self)
    end

    def handle_event(id, data)
      send_data full_json_hash
    end

    def full_json_hash
      Hash[@instance.projects.map {|project|
        [project.id, {
          builds: project.recent_builds.map {|build| {
            id:     build.id,
            stages: build.stages.map {|stage| {
              id:    stage.id,
              state: stage.state
            }}
          }}
        }]
      }].to_json
    end
  end
end
