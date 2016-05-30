require 'sendgrid-ruby'
require 'uri'
require 'net/http'

class TaskController < ApplicationController
  skip_before_filter :authenticate 
  
  def notify_user_daily
    
    puts "Method invoked by: " + (params[:callid].nil? ? "nil" : params[:callid])
    
    @draw_date = Date.yesterday
    @lotto_results = LottoResult.where(draw_date: @draw_date).order("jackpot_prize DESC, game ASC")
    first_result = @lotto_results[0]
    users = FbUser.joins(:user_setting).where(user_settings: { email_verification: 'ok', notify_daily_results: true })
    users.each do |u|     
      @user = u
      mail_body = render_to_string :template => '/mail/daily_results', layout: 'mailer'
      mail_info = {
          to: u.email,
          from: 'Lotto Analytics <no-reply@' + request.domain + '>',
          subject: ('[Daily Results] ' + first_result.game + ': ' + first_result.numbers),
          html: mail_body
      }
      EmailUtil.send mail_info
    end
    
    render json: users.map{ |u| u.email }
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
    
    render json: rows.map{ |row| LottoResultUtil.parse(row).to_s }.to_s
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
end
