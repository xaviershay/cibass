require 'cibass/build'

class Cibass

  # A project is a mapping between a git repository and a pipeline. One
  # git repository can be submitted to multiple pipelines, in which case
  # it would be represented by multiple projects.
  #
  # A project can contain any commits inside a repository. Logic for only
  # building commits from a specific branch will be handled in the elsewhere
  # in the subsystem responsible for getting builds into the system.
  class Project < Struct.new(:event_bus, :id, :pipeline)

    def initialize(*args)
      super
      @builds = {}
    end

    def build(id, &block)
      @builds.fetch(id, &block)
    end

    def create_build(refspec)
      Cibass::Build.new(self, refspec, :not_started).tap do |build|
        pipeline.stages.each do |stage_id|
          build.add_stage(stage_id)
        end
        @builds[refspec] = build
        event_bus.push_event(:build_created,
          project: self,
          build:   build
        )
      end
    end

    def recent_builds
      @builds.values
    end

    def push_event(id, data)
      event_bus.push_event id, data.merge(project: self)
    end
  end
end
