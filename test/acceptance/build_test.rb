require_relative 'acceptance_helper'

class BuildTest < AcceptanceTest
  def test_skeleton
    server = start_server <<-RUBY
      Cibass.configure do |config|
      end
    RUBY

    status, _, body = get(server, '/')
    assert_equal 200,      status
    assert_equal "Cibass", body.join
  end

  def get(server, path)
    env = Rack::MockRequest.env_for(path, "REQUEST_METHOD" => "GET")
    server.call(env)
  end

  def start_server(config_contents)
    working = create_working_dir
    config = create_config_repo(config_contents)

    server = Cibass::Server.new(
      :working_directory => working,
      :config_repository => config,
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

  def teardown
    super
    (@cleanup || []).each do |x|
      `rm -rf #{x}`
    end
  end
end
