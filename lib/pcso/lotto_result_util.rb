require 'uri'
require 'net/http'

class LottoResultUtil
  
  def self.get_daily_results_by_range(str_from_date, str_to_date = str_from_date)
    
    url = URI.parse("https://www.pcso.gov.ph/SearchLottoResult.aspx")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http = http.start
    request = Net::HTTP::Get.new(url)
    response = http.request(request)
    

    from_date = str_from_date.nil? ? Date.today : DateTime.parse(str_from_date)
    to_date = str_to_date.nil? ? Date.today : DateTime.parse(str_to_date)

    respText = response.read_body   
    prefix = 'ctl00$ctl00$cphContainer$cpContent$'
    
    formData = {'__VIEWSTATE' => extract_form_value('__VIEWSTATE', respText),
        '__VIEWSTATEGENERATOR' => extract_form_value('__VIEWSTATEGENERATOR', respText),
        '__EVENTVALIDATION' => extract_form_value('__EVENTVALIDATION', respText),
        prefix + 'ddlStartMonth' => from_date.strftime("%B"),
        prefix + 'ddlStartDate' => from_date.strftime("%-d"),  #%-d removes leading zeroes; %d outputs "09" while %-d is "9"
        prefix + 'ddlStartYear' => from_date.strftime("%Y"),
        prefix + 'ddlEndMonth' => to_date.strftime("%B"),
        prefix + 'ddlEndDay' => to_date.strftime("%-d"),
        prefix + 'ddlEndYear' => to_date.strftime("%Y"),
        prefix + 'ddlSelectGame' => '0',
        prefix + 'btnSearch' => 'Search Lotto'    
      }
    #print formData.inspect
      
    req = Net::HTTP::Post.new(url.request_uri)
    req.set_form_data(formData)
    http.use_ssl = (url.scheme == "https")
    
    response = http.request(req)
    
    body_text = response.read_body
    
    rows = body_text[body_text.index('LOTTO GAME')..-1].scan(/<tr.*?<\/tr>/m)
    
    return rows.map{ |row| LottoResultUtil.parse(row) }.select{ |row| row }
  end
  
  def self.get_daily_results_from_file
    
    body_text = File.read(File.dirname(__FILE__) + "/../../tmp/sample_lotto_result.html")
    rows = body_text[body_text.index('LOTTO GAME')..-1].scan(/<tr.*?<\/tr>/m)
    @result = "from file: " + rows.map{ |row| LottoResultUtil.parse(row).to_s }.to_s
  end
    
   def self.parse(htmltext) 
     
     cells = htmltext.scan(/<td>.*?<\/td>/m)
     
     return LottoResult.new(
       game:     cells[0].sub(/.*>(.*)<.*/, '\1'), 
       numbers:       cells[1].sub(/.*>(.*)<.*/, '\1'), 
       draw_date:     Date.strptime(cells[2].sub(/.*>(.*)<.*/, '\1'), "%m/%d/%Y"), 
       jackpot_prize: cells[3].sub(/.*>(.*)<.*/, '\1').gsub(',','').to_i, 
       winners:       cells[4].sub(/.*>(.*)<.*/, '\1').to_i)
     

   end
  
  private 
  
    def self.extract_form_value(fieldname, text_to_extract)
      kvText = /id="#{fieldname}"\s+value=".*?"/.match(text_to_extract).to_s
      return kvText.sub(/.*?value="(.*)"/, '\1')
    end
   
end