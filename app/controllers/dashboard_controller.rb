class DashboardController < ApplicationController
  protect_from_forgery with: :null_session
    
    def index
      @user = current_user
      @user_num_list = current_user.user_numbers
    end
    
    def has_won(user_number)
     # this is for 3D and 2D draws, to query if it has won regardless 11AM, 4PM or 9PM draws
      num = '-' + user_number.numbers.split('-').sort.join('-') + '-'
      return LottoResult.joins(:lotto_game).where(sorted_numbers: num, draw_date: Date.yesterday, lotto_games: {group_name: user_number.lotto_game.group_name}).any?
  
     # this is for normal scenarios
     # num = user_number.numbers.split('-').join('-')
     # return LottoResult.where(numbers: num, draw_date: Date.yesterday, lotto_game_id: user_number.lotto_game_id).any?
    end
    
    def get_add_number_form
      render action: 'add_number_form', layout: false
    end
    
    def search_number
      token = params[:q].split('-').map{|x|x.to_i}.sort.join('-')
      @results = LottoResult.where('sorted_numbers LIKE ?', "%#{token}%").order(draw_date: :desc).limit(20);
      render action: 'number_search_results', layout: false
    end
    
    def get_number_details
      nums = params[:numbers].split('-').map{|n| n.to_i % 2 }
      @even_count = nums.count(0)
      @odd_count = nums.count(1)
      render action: 'get_number_details', layout: false
    end
       
    def ajax_add_number
      row = UserNumber.new(
        numbers: params[:numbers],
        fb_user_id: current_user.id,
        lotto_game_id: params[:game_id]);
      row.save
      render json: row
    end
    
    def ajax_remove_number
      result = UserNumber.find(params[:id]).destroy
      render json: result
    end
    
    def ajax_copy_result_to_user_number
      res = LottoResult.find(params[:lotto_result_id])
      row = UserNumber.new(lotto_game_id: res.lotto_game_id, numbers: res.numbers, fb_user_id: current_user.id)
      row.save
      render json: row
    end
    
end
