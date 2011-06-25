require_relative 'acceptance_helper'

class BuildTest < AcceptanceTest
  def test_skeleton
    server = start_server <<-RUBY
      Cibass.configure do |config|
      end
    RUBY

    in_session browser(server) do
      get '/'
      assert_equal "Cibass", body
    end
  end

  def test_manual_build
    project = create_git_repository

    server = start_server <<-RUBY
      Cibass.configure do |config|
        config.create_pipeline(:manual) do |pipe|
          pipe.add_stage(:uat)
        end

        config.connect('#{project.git.work_tree}', to: :main)
      end
    RUBY

    in_session json_browser_for_commit(server, 'main', project.commits[0]) do
      put ''
      get '/uat'
      assert_equal 'not_started', body['state']

      put '/uat/succeeded'
      get '/uat'
      assert_equal 'succeeded', body['state']
    end
  end

  def start_server(config_contents)
    working = create_working_dir
    config = create_config_repo(config_contents)

    Cibass::Server.new(
      :working_directory => working,
      :config_repository => config
    )
  end

  def create_working_dir
    (@cleanup ||= []) << Dir.mktmpdir
  end

  def create_config_repo(config)
    dir = Dir.mktmpdir
    (@cleanup ||= []) << dir
    Dir.chdir(dir) do
      `git init`
      File.open("Cibass", "w") {|f| f.write(config) }
      `git add -A`
      `git commit -m "Initial"`
    end
    dir
  end

  def create_git_repository
    dir = Dir.mktmpdir
    (@cleanup ||= []) << dir
    Dir.chdir(dir) do
      `git init`
      File.open("README", "w") {|f|  }
      `git add -A`
      `git commit -m "Initial"`
    end
    Grit::Repo.new(dir)
  end

  def teardown
    super
    (@cleanup || []).each do |x|
      `rm -rf #{x}`
    end
  end
end
