require 'uri'
require 'net/http'

class PseUtil
  
  def self.get_stock_info(code)
    
    url = URI.parse("https://bpitrade.cdn.technistock.net/quotes/si-bna-10Lvl.asp?list=20&list2=10&code=" + code)
    http = Net::HTTP.new(url.host, url.port)
    http = http.start
    request = Net::HTTP::Get.new(url)
    response = http.request(request)
    
    return response.read_body

  end
   
end