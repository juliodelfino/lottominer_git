class DashboardController < ApplicationController

    def index
      @user = current_user
    end
    
    def get_add_number_form
      render action: 'add_number_form', layout: false
    end
end
