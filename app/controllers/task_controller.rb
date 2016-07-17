require 'sendgrid-ruby'

class TaskController < ApplicationController
  skip_before_filter :authenticate 
  
  # Fetches daily results from PCSO website. Performs hourly check
  # to handle cases when PCSO has not posted the latest results yet,
  # or when PCSO website is down temporarily.
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
      @daily_results = LottoResultUtil.get_daily_results_by_range(selectedDate.strftime("%Y%m%d"))
    end
    
    if (@daily_results.size > 0)
      update_current_jackpot_prizes
      update_winning_user_numbers(@daily_results[0].draw_date)
      notify_user_by_date(@daily_results[0].draw_date)
    end
    
    render json: @daily_results
  end
 
  # Fetches draw results by range.
  # Example: lotto.jdelfino.com/get_daily_results?from=20160701&to=20160716
  # This example fetches results from July 1 to 16, 2016.
  def get_daily_results
    
    puts "Method invoked by: " + (params[:callid].nil? ? "nil" : params[:callid])
    render json: LottoResultUtil.get_daily_results_by_range(params[:from], params[:to])
  end
  
  # Sends the mails that are queued in 'emails' table in the database.
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
      e.status = ('200' == send_result) ? :SENT : send_result
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
  
  def update_winning_user_numbers(date)
    UserNumber.update_all won: false
    LottoResult.where(draw_date: date).each do |result|
      UserNumber.where(lotto_game_id: result.lotto_game_id, numbers: result.numbers).update_all won: true
    end
  end
  
  def update_current_jackpot_prizes
    LottoGame.all.each do |g|
      sample_result = LottoResult.where(lotto_game_id: g.id).order(draw_date: :DESC).limit(1)[0]
      if (!["2D", "3D"].include?(g.group_name) && sample_result.winners > 0)
        sample_result = LottoResult.where(lotto_game_id: g.id).order(jackpot_prize: :ASC).limit(1)[0]
      end
      g.current_jackpot_prize = sample_result.jackpot_prize
      g.save
    end
  end
  
end
