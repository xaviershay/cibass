require 'cibass'
require 'cibass/event_bus'
require 'cibass/config_loader'
require 'cibass/project'

class Cibass

  # The main controller class for the application. It allows access to the
  # projects specified in the configuration, and pushes out event/change
  # notifications to interested objects.
  class Instance

    include EventBus

    def initialize(opts)
      @opts = opts
      @current = {}
      @config = ConfigLoader.new(
        opts[:config_repository],
        opts[:working_directory]
      ).current_config

      # This will eventually be persisted somewhere
      @config.projects.each do |project, data|
        @current[project.to_s] = Cibass::Project.new(self, project, data[:pipeline])
      end
    end

    def project(id, &block)
      @current.fetch(id.to_s, &block)
    end

    def projects
      @current.values
    end

  end
end
