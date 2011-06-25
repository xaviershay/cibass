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

end
