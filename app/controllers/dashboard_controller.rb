class DashboardController < ApplicationController
  protect_from_forgery with: :null_session
    
    def index
      @user = current_user
    end
    
    def get_add_number_form
      render action: 'add_number_form', layout: false
    end
    
    def search_number
      token = params[:q]
      @results = LottoResult.where('numbers LIKE ?', "%#{token}%").order(draw_date: :desc).limit(20);
      render action: 'number_search_results', layout: false
    end
    
    def get_number_details
      nums = params[:numbers].split(',').map{|n| n.to_i % 2 }
      @odd_even_info = pluralize(nums.count(1), 'odd') + ', ' + pluralize(nums.count(0), 'even')
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
