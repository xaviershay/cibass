require_relative 'acceptance_helper'

class SkeletonTest < AcceptanceTest

  def test_skeleton
    server = start_server <<-RUBY
      Cibass.configure do |config|
      end
    RUBY

    in_session browser(server) do
      get '/'
      assert_includes body, "Cibass"
    end
  end

end
