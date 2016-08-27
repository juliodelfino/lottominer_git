class DashboardController < ApplicationController
  protect_from_forgery with: :null_session
    
    def index
      @user = current_user
      @user_num_list = current_user.user_numbers
    end
    
    def get_add_number_form
      render action: 'add_number_form', layout: false
    end
    
    def search_number
      token = params[:q].split('-').map{|x|x.rjust(2, '0')}.sort.join('%')
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
      
      sorted_nums = '-' + params[:numbers].split('-').map{ |x| x.rjust(2, '0')}.sort.join('-') + '-'
      row = UserNumber.new(
        numbers: params[:numbers].split('-').join('-'),
        fb_user_id: current_user.id,
        lotto_game_id: params[:game_id],
        sorted_numbers: sorted_nums);
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
