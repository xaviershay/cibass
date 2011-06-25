class Cibass

  class Config

    attr_reader :builds

    def initialize
      @pipelines = []
      @builds = {}
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

      @builds[build_id] = {
        repository: repository,
        pipeline:   pipeline
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
    end
  end

end
