require 'cibass/stage'

class Cibass
  
  # A build is an instance of a specific commit in a project that is in
  # the pipeline. Only one build can exist for a given commit, the outcome
  # should be deterministic. If a "rebuild" is required, for instance due
  # to a build server configuration problem, it should be canceled and resubmitted
  # to the pipeline.
  class Build < Struct.new(:event_bus, :id, :state)
    
    def initialize(*args)
      super
      @stages = {} 
    end

    def stage(id, &block)
      @stages.fetch(id.to_s, &block)
    end

    def add_stage(id)
      @stages[id.to_s] = Stage.new(self, id)
    end

    def stages
      @stages.values
    end

    def push_event(id, data)
      event_bus.push_event id, data.merge(build: id)
    end

  end
end
