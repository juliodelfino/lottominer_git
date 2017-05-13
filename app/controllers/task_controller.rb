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
      LottoResult.transaction do
        @daily_results = LottoResultUtil.get_daily_results_by_range(selectedDate.strftime("%Y%m%d"))
      end
    end
    
    if (@daily_results.size > 0)
      Thread.new do
        update_current_jackpot_prizes
        update_winning_user_numbers(@daily_results[0].draw_date)
        notify_user_by_date(@daily_results[0].draw_date)
      end
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
    subs = Subscription.where(enabled: true, notify_daily_results: true)
    subs.each do |s|     
      @subscription = s
      mail_body = render_to_string :template => '/mail/daily_results', layout: 'mailer'
      db_email = Email.new(
        recipient: s.email,
        subject: ('[DR] ' + first_result.game + ': ' + first_result.numbers),
        body: mail_body,
        plan_send_date: DateTime.now,
        status: :QUEUED)
      db_email.save
    end
    
    return subs.map{ |s| s.email }
  end
  
  def update_winning_user_numbers(date)
    UserNumber.transaction do
      UserNumber.update_all won: false, status: ''
      LottoResult.joins(:lotto_game).where(draw_date: date).each do |result|
        puts 'results here: ' + result.numbers
        if result.lotto_game.group_name.starts_with?('6D')
          match_sql = sprintf('lotto_game_id = %s AND (%s)', result.lotto_game_id, sql_for_match(result.numbers, 3))
          UserNumber.where(match_sql).update_all won: true, status: 'MATCH 3'
          match_sql = sprintf('lotto_game_id = %s AND (%s)', result.lotto_game_id, sql_for_match(result.numbers, 4))
          UserNumber.where(match_sql).update_all won: true, status: 'MATCH 4'
          match_sql = sprintf('lotto_game_id = %s AND (%s)', result.lotto_game_id, sql_for_match(result.numbers, 5))
          UserNumber.where(match_sql).update_all won: true, status: 'MATCH 5'
          sorted_wnumbers = '-' + result.numbers.split('-').map{ |x| x.rjust(2, '0')}.sort.join('-') + '-'
          UserNumber.where(lotto_game_id: result.lotto_game_id, sorted_numbers: sorted_wnumbers).update_all won: true, status: 'JACKPOT'
        else
          # for rambolito numbers
          UserNumber.where(lotto_game_id: result.lotto_game_id, sorted_numbers: result.numbers).update_all won: true, status: 'WINNER'
        end
      end
    end
  end
  
  # TODO: merge with logic in update_winning_user_numbers() function
  def has_won(user_number)
   # this is for 3D and 2D draws, to query if it has won regardless 11AM, 4PM or 9PM draws
    num = '-' + user_number.numbers.split('-').sort.join('-') + '-'
    return LottoResult.joins(:lotto_game).where(sorted_numbers: num, draw_date: Date.yesterday, lotto_games: {group_name: user_number.lotto_game.group_name}).any?

   # this is for normal scenarios
   # num = user_number.numbers.split('-').join('-')
   # return LottoResult.where(numbers: num, draw_date: Date.yesterday, lotto_game_id: user_number.lotto_game_id).any?
  end
  
  def sql_for_match(numbers, match_count)
    wnums = numbers.split('-').map(&:to_i).sort
    idx_permutations = [0,1,2,3,4,5].combination(match_count).to_a
    sqls = idx_permutations.map{ |p| 'sorted_numbers LIKE \'%' + wnums.values_at(*p).map{ |x| x.to_s.rjust(2, '0')}.join('%') + '%\'' }
    return sqls.join(' OR ')
  end
  
  def update_current_jackpot_prizes
    LottoGame.transaction do
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
  
end
