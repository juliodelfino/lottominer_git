class WelcomeController < ApplicationController
  skip_before_filter :authenticate 
    
  def index   
    compute_results
  end
  
  def unsubscribe
    user = FbUser.find_by(fb_id: params[:id])
    if (user.present?)
      user.user_setting.notify_daily_results = false
      user.user_setting.save
      render '/mail/unsubscribed'
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end
  
  def about
  end
  
  def test_email
    @user = current_user
    @draw_date = Date.yesterday
    @lotto_results = LottoResult.where(draw_date: @draw_date).order("jackpot_prize DESC, game ASC")
    txt = render_to_string :template => '/mail/daily_results', layout: 'mailer'
    render text: txt
  end
  
  def ajax_results
    compute_results
    render action: '_results', layout: false
  end
  
  private
    def compute_results
      @selected_date = (params[:date].nil? || DateTime.parse(params[:date]) > Date.yesterday)? \
      Date.yesterday : DateTime.parse(params[:date])
      @prev_date = (@selected_date - 1.days).strftime("%Y%m%d")
      @next_date = (@selected_date + 1.days).strftime("%Y%m%d")
      all_results = LottoResult.where(draw_date: @selected_date).order("jackpot_prize DESC, game ASC")
      if (all_results.size == 0) 
        latest_on_db = LottoResult.order(draw_date: :desc).limit(1)[0];
        @selected_date = latest_on_db.draw_date;
        all_results = LottoResult.where(draw_date: @selected_date).order("jackpot_prize DESC, game ASC")
      end
      @latest_result = all_results[0]
      @other_results = all_results[1..all_results.length-1]
    end
end
