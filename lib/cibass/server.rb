require 'sinatra/base'

require 'cibass'

class Cibass

  class Config
  end

  class Server < Sinatra::Base

    configure :test do
      enable :raise_errors
      disable :show_exceptions
    end

    attr_reader :opts, :config

    def initialize(opts)
      super()
      @opts = opts
      setup
    end

    def setup
      update_config
      load_config
    end

    get '/' do
      "Cibass"
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
    end

    def config_file
      File.join(config_directory, 'Cibass')
    end

    def config_directory
      File.join(opts[:working_directory], 'config')
    end

  end
end
