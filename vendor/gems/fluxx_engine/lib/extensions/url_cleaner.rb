require "uri"

module URLCleaner
  def clean_url(url)
    begin
      uri = URI.parse url

      if !(uri.scheme && uri.host)
        return URI.parse('http://' + url).to_s
      end

      return uri.to_s
    rescue
      return url
    end
  end
end