class NetworkUtil
  def self.https_get(url)
    
    require "net/http"
    require "uri"
    uri = URI.parse(url)

    response = Net::HTTP.start(uri.host, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      http.get uri.request_uri, 'User-Agent' => 'MyLib v1.2'
    end
    return response.body
  end
end
