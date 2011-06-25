class BrowserDriver < Struct.new(:server)

  attr_reader :status, :headers, :body, :requested_path
  attr_accessor :prefix

  def get(path)
    request("GET", path)
  end

  def put(path)
    request("PUT", path)
  end

  def request(http_method, path)
    @requested_path = make_path(path)
    env = Rack::MockRequest.env_for(@requested_path, headers.merge(
      "REQUEST_METHOD" => http_method
    ))
    @status, @headers, body = server.call(env)
    @body = process_body(body)
  end

  def process_body(body)
    body.join
  end

  def make_path(original_path)
    prefix.to_s + original_path
  end

  def headers
    {}
  end

end
