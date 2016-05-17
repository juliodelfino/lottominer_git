class DashboardController < ApplicationController
    
    def index
      @user = current_user
    end
    
    def get_add_number_form
      render action: 'add_number_form', layout: false
    end
    
    def search_number
      token = params[:token]
      @results = LottoResult.where('numbers LIKE ?', "%#{token}%").order(draw_date: :desc).limit(20);
      render action: 'number_search_results', layout: false
    end
end
