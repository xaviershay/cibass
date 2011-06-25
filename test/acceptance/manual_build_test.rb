require_relative 'acceptance_helper'

class BuildTest < AcceptanceTest
  def setup
    super

    @project = create_git_repository

    @server = start_server <<-RUBY
      Cibass.configure do |config|
        config.create_pipeline(:manual) do |pipe|
          pipe.add_stage(:uat)
        end

        config.connect('#{@project.git.work_tree}', to: :main)
      end
    RUBY
  end

  def setup_build
    put ''
    get '/uat'
    assert_equal 'not_started', body['state']
  end

  def driver
    json_browser_for_commit(@server, 'main', @project.commits[0])
  end

  def test_succeeding_manual_build
    in_session(driver) do
      setup_build

      put '/uat/succeeded'
      get '/uat'
      assert_equal 'succeeded', body['state']
    end
  end

  def test_failing_manual_build
    in_session(driver) do
      setup_build

      put '/uat/failed'
      get '/uat'
      assert_equal 'failed', body['state']
    end
  end

end
