class Cibass

  class Config

    attr_reader :projects

    def initialize
      @pipelines = []
      @projects = {}
    end

    def create_pipeline(id)
      Pipeline.new(id).tap do |pipeline|
        yield pipeline
        @pipelines << pipeline
      end
    end

    def connect(repository, args)
      pipeline = args[:to]
      build_id = args[:to]

      @projects[build_id] = {
        repository: repository,
        pipeline:   @pipelines.detect {|x| x.id == pipeline }
      }
    end

    class Pipeline < Struct.new(:id)
      def initialize(*args)
        super
        @stages = {}
      end

      def add_stage(id)
        @stages[id] = {}
      end

      def stages
        @stages.keys
      end
    end
  end

end
