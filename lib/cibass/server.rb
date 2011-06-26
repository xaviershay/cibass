require 'sinatra/base'

class Cibass

  class Server < Sinatra::Base
    set :views,  File.expand_path("../ui/views", __FILE__)
    enable :logging

    configure :test do
      enable :raise_errors
      disable :show_exceptions
    end

    attr_reader :instance

    def initialize(instance)
      @instance = instance
      super()
    end

    not_found do
      if request.env['CONTENT_TYPE'] == 'application/json'
        {}.to_json
      else
        not_found
      end
    end

    get '/' do
      erb :index
    end

    get '/main.js' do
      coffee :main
    end

    # Ideally this would be routed through the public directory.
    get '/jquery.js' do
      headers :'Content-Type' => 'text/javascript'
      File.read File.expand_path("../ui/static/jquery.min.js", __FILE__)
    end

    put '/:build/:refspec' do
      current_project.create_build(params[:refspec])
      empty_response 201
    end

    get '/:build/:refspec/:stage' do
      {
        state: current_stage.state
      }.to_json
    end

    put '/:build/:refspec/:stage/succeeded' do
      current_stage.succeeded!
      empty_response 201
    end

    put '/:build/:refspec/:stage/failed' do
      current_stage.failed!
      empty_response 201
    end

    def current_project
      instance.project(params[:build]) { not_found }
    end

    def current_build
      current_project.build(params[:refspec]) { not_found }
    end

    def current_stage
      current_build.stage(params[:stage]) { not_found }
    end

    def empty_response(status_code)
      status status_code
      {}.to_json
    end

  end
end
