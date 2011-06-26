class Cibass

  # Responsible for fetching and loading the latest version of the cibass
  # configuration from the configuration repository. A persistent working
  # directory should be given so that the repository does not need to be
  # re-cloned every time it needs to be accessed.
  class ConfigLoader < Struct.new(:config_repository, :working_directory)

    # Below here needs to probably be moved out of this class
    def update_config
      if !File.exists?(config_directory)
        `git clone #{config_repository} #{config_directory}`
      end
      Dir.chdir(config_directory) do
        `git fetch`
        `git reset --hard origin/master`
      end
    end

    def current_config
      @current_config ||= begin
        update_config
        Cibass.instance = self
        load config_file
        Cibass.config
      end
    end

    def config_file
      File.join(config_directory, 'Cibass')
    end

    def config_directory
      File.join(working_directory, 'config')
    end

  end

end
