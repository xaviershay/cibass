require 'minitest/unit'
require 'minitest/autorun'

require 'tmpdir'

require_relative '../support/enforce_max_run_time'

$LOAD_PATH.unshift File.expand_path("../../../lib", __FILE__)

require 'cibass/server'

class AcceptanceTest < MiniTest::Unit::TestCase

  include EnforceMaxRunTime

  def max_run_time
    0.25
  end

end
