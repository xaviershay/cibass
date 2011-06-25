require 'minitest/unit'
require 'minitest/autorun'

require 'json'
require 'tmpdir'
require 'pathname'

require 'grit'

require_relative '../support/enforce_max_run_time'
require_relative 'support/http_session'

$LOAD_PATH.unshift File.expand_path("../../../lib", __FILE__)

ENV['RACK_ENV'] = 'test'
require 'cibass/server'

class AcceptanceTest < MiniTest::Unit::TestCase

  include EnforceMaxRunTime
  include HttpSession

  def max_run_time
    0.25
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
