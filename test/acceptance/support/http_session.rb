require_relative 'browser_driver'
require_relative 'json_browser_driver'
require_relative '../../support/exception_formatter'

module HttpSession

  include ExceptionFormatter

  def browser(server)
    BrowserDriver.new(server)
  end

  def json_browser_for_commit(server, build, refspec)
    JsonBrowserDriver.new(server).tap do |driver|
      driver.prefix = "/%s/%s" % [build, refspec]
    end
  end

  def in_session(driver)
    old_driver = @driver
    @driver = driver
    yield
  ensure
    @driver = old_driver
  end

  def get(path)
    @driver.get(path)
    assert_equal 200, status, "Response to #{requested_path} was not successful"
  rescue => e
    flunk("GET to #{requested_path} failed:\n#{format_exception(e)}")
  end

  def put(path)
    @driver.put(path)
    assert_equal 201, status, "Put to #{requested_path} was not successful"
  rescue => e
    flunk("PUT to #{requested_path} failed:\n#{format_exception(e)}")
  end

  def body
    @driver.body
  end

  def status
    @driver.status
  end

  def requested_path
    @driver.requested_path
  end

end
