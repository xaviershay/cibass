class JsonBrowserDriver < BrowserDriver
  def headers
    {
      "CONTENT_TYPE"   => "application/json"
    }
  end

  def process_body(body)
    text = body.join
    JSON.parse(text)
  rescue JSON::ParserError => e
    raise e.exception("#{text.inspect} was not valid JSON (#{e.message})")
  end
end
