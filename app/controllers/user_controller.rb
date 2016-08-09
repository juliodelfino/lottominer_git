class UserController < ApplicationController  
  def settings  
    @db_user = current_user   
  end
  
  def save_settings
    current_user.update(user_params)
    current_user.user_setting.update(user_setting_params)
    #redirect_to '/dashboard'
    render text: 'ok'
  end
  
    private
      def user_params
        params.require(:user).permit(:email, :name)
      end
      
      def user_setting_params
        return {
          :notify_daily_results => (params[:notify_daily_results] == 'true')
        }
      end
      
end
