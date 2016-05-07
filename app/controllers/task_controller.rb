require 'sendgrid-ruby'
require 'uri'
require 'net/http'

class TaskController < ApplicationController
  
  def notify_user_daily
    
    puts "Method invoked by: " + (params[:callid].nil? ? "nil" : params[:callid])
    send_lotto_mail
  end
  
  def get_daily_results
    
    puts "Method invoked by: " + (params[:callid].nil? ? "nil" : params[:callid])
    
    url = URI.parse("http://www.pcso.gov.ph/lotto-search/lotto-search.aspx")
    http = Net::HTTP.new(url.host, url.port)
    http = http.start
    request = Net::HTTP::Get.new(url)
    response = http.request(request)
    

    from_date = params[:from].nil? ? Date.today : DateTime.parse(params[:from])
    to_date = params[:to].nil? ? Date.today : DateTime.parse(params[:to])
    
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
    
    @result = rows.map{ |row| LottoResultUtil.parse(row).to_s }.to_s
  end
  
  def get_daily_results_from_file
    
    body_text = File.read(File.dirname(__FILE__) + "/../../tmp/sample_lotto_result.html")
    rows = body_text[body_text.index('LOTTO GAME')..-1].scan(/<tr.*?<\/tr>/m)
    @result = "from file: " + rows.map{ |row| LottoResultUtil.parse(row).to_s }.to_s
  end
  
  private 
  
    def extract_form_value(fieldname, text_to_extract)
      kvText = /id="#{fieldname}"\s+value=".*?"/.match(text_to_extract).to_s
      return kvText.sub(/.*?value="(.*)"/, '\1')
    end
  

    def send_lotto_mail
      
      lotto_result = LottoResult.where(draw_date: Date.yesterday).order(jackpot_prize: :desc).limit(1)[0]
        
      mail_info = {
        to: 'jhackr@gmail.com',
        from: 'sofia@lottominer.com',
        subject: lotto_result.game + ': ' + lotto_result.numbers,
        text: DateTime.now.strftime(" on %m-%d-%Y at at %I:%M%p") \
             + '\nHere are the lotto results:\nGame: ' + lotto_result.game + "\nResults: " + lotto_result.numbers \
             + '\nJSON info: ' + lotto_result.to_json
      }
      
      EmailUtil.send mail_info
    end
end
