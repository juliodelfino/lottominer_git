require 'sendgrid-ruby'
require 'uri'
require 'net/http'

class TaskController < ApplicationController
  skip_before_filter :authenticate 
  
  def send_mails
    mails = []
    dateNow = DateTime.now
    Email.where("status = ? AND plan_send_date <= ?", :QUEUED, dateNow).each do |e|
      mail_info = {
          to: e.recipient,
          from: 'Lotto Analytics <no-reply@' + request.domain + '>',
          subject: e.subject,
          html: e.body
      }
      mails << e.recipient
      send_result = EmailUtil.send(mail_info)
      e.status = ('200' == send_result) ? :OK : send_result
      e.actual_send_date = DateTime.now
      e.save
    end
    
    render json: mails
  end
  
  
  def notify_user_daily
    
    puts "Method invoked by: " + (params[:callid].nil? ? "nil" : params[:callid])
    
    render json: notify_user_by_date
  end
  
  def notify_user_by_date(selected_date = Date.yesterday)
    @draw_date = selected_date
    @lotto_results = LottoResult.where(draw_date: @draw_date).order("jackpot_prize DESC, game ASC")
    
    first_result = @lotto_results.find{ |r| r.lotto_game.group_name.start_with?('6D') && r.winners > 0 }
    first_result = @lotto_results[0] if (first_result.nil?)
    users = FbUser.joins(:user_setting).where(user_settings: { email_verification: 'ok', notify_daily_results: true })
    users.each do |u|     
      @user = u
      mail_body = render_to_string :template => '/mail/daily_results', layout: 'mailer'
      db_email = Email.new(
        recipient: u.email,
        subject: ('[DR] ' + first_result.game + ': ' + first_result.numbers),
        body: mail_body,
        plan_send_date: DateTime.now,
        status: :QUEUED)
      db_email.save
    end
    
    return users.map{ |u| u.email }
  end
  
  
  def get_daily_results_from_pcso
     
    hourNow = Time.now.in_time_zone('Singapore').hour
    drawHour = 21 #draw time is 09:00PM or 21:00
    @daily_results = []
    selectedDate = nil
    if (hourNow < drawHour)
      selectedDate = DateTime.now.prev_day.in_time_zone('Singapore').to_date
    else
      selectedDate = Date.today.in_time_zone('Singapore')
    end
    
    result_count = LottoResult.where(draw_date: selectedDate).count
    if (0 == result_count)
      @daily_results = get_daily_results_by_range(selectedDate.strftime("%Y%m%d"))
    end
    
    if (@daily_results.size > 0)
      notify_user_by_date(@daily_results[0].draw_date)
    end
    
    render json: @daily_results
  end
  
  def get_daily_results
    
    puts "Method invoked by: " + (params[:callid].nil? ? "nil" : params[:callid])
    render json: get_daily_results_by_range(params[:from], params[:to])
  end
  
  def get_daily_results_by_range(str_from_date, str_to_date = str_from_date)
    
    url = URI.parse("http://www.pcso.gov.ph/lotto-search/lotto-search.aspx")
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
