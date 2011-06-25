require 'sinatra/base'

require 'cibass'

class Cibass

  class Server < Sinatra::Base

    configure :test do
      enable :raise_errors
      disable :show_exceptions
    end

    attr_reader :opts, :config

    def initialize(opts)
      super()
      @opts = opts
      @current = {}
      setup
    end

    def setup
      update_config
      load_config
    end

    get '/' do
      "Cibass"
    end

    put '/:build/:refspec' do
      current_project[params[:refspec]] = {
        state: 'not_started'
      }

      empty_response 201
    end

    get '/:build/:refspec/:stage' do
      {
        state: current_build[:state]
      }.to_json
    end

    put '/:build/:refspec/:stage/succeeded' do
      current_build.update(
        state: 'succeeded'
      )

      empty_response 201
    end

    def current_project
      @current.fetch(params[:build]) { not_found }
    end

    def current_build
      current_project.fetch(params[:refspec]) { not_found }
    end

    def empty_response(status_code)
      status status_code
      {}.to_json
    end

    def update_config
      if !File.exists?(config_directory)
        `git clone #{opts[:config_repository]} #{config_directory}`
      end
      Dir.chdir(config_directory) do
        `git fetch`
        `git reset --hard origin/master`
      end
    end

    def load_config
      Cibass.instance = self
      load config_file
      @config = Cibass.config

      @config.builds.each do |build, _|
        @current[build.to_s] = {}
      end
    end

    def config_file
      File.join(config_directory, 'Cibass')
    end

    def config_directory
      File.join(opts[:working_directory], 'config')
    end

  end
end
