require 'uri'
require 'net/http'

class LottoResultUtil
  
  def self.get_daily_results_by_range(str_from_date, str_to_date = str_from_date)
    
    url = URI.parse("http://www.pcso.gov.ph/search-lotto-results/lotto-search.aspx")
    http = Net::HTTP.new(url.host, url.port)
    http = http.start
    request = Net::HTTP::Get.new(url)
    response = http.request(request)
    

    from_date = str_from_date.nil? ? Date.today : DateTime.parse(str_from_date)
    to_date = str_to_date.nil? ? Date.today : DateTime.parse(str_to_date)
    
    respText = response.read_body
    
    formData = {'__VIEWSTATE' => extract_form_value('__VIEWSTATE', respText),
        '__VIEWSTATEGENERATOR' => extract_form_value('__VIEWSTATEGENERATOR', respText),
        '__EVENTVALIDATION' => extract_form_value('__EVENTVALIDATION', respText),
        'ddlStartMonth' => from_date.strftime("%B"),
        'ddlStartDate' => from_date.strftime("%-d"),  #%-d removes leading zeroes; %d outputs "09" while %-d is "9"
        'ddlStartYear' => from_date.strftime("%Y"),
        'ddlEndMonth' => to_date.strftime("%B"),
        'ddlEndDay' => to_date.strftime("%-d"),
        'ddlEndYear' => to_date.strftime("%Y"),
        'ddlSelectGame' => '0',
        'btnSearch' => 'Search Lotto'    
      }
      
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
     
     row = LottoResult.new(
       game:     cells[0].sub(/.*>(.*)<.*/, '\1'), 
       numbers:       cells[1].sub(/.*>(.*)<.*/, '\1'), 
       draw_date:     Date.strptime(cells[2].sub(/.*>(.*)<.*/, '\1'), "%m/%d/%Y"), 
       jackpot_prize: cells[3].sub(/.*>(.*)<.*/, '\1').gsub(',','').to_i, 
       winners:       cells[4].sub(/.*>(.*)<.*/, '\1').to_i)
     
     if (LottoResult.find_by(game: row.game, draw_date: row.draw_date).nil?)
       nums = row.numbers.split('-').map{ |x| x.rjust(2, '0') }.sort
       row.sorted_numbers = '-' + nums.join('-') + '-'
       game = LottoGame.where(name: row.game)[0]
       row.lotto_game_id = game.id
       row.save
       return row
     else
       return false
     end
   end
  
  private 
  
    def self.extract_form_value(fieldname, text_to_extract)
      kvText = /id="#{fieldname}"\s+value=".*?"/.match(text_to_extract).to_s
      return kvText.sub(/.*?value="(.*)"/, '\1')
    end
   
end