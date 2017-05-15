class UserController < ApplicationController  
  def settings  
    @db_user = current_user  
    @subscription = Subscription.where(:email => @db_user.email).first
  end
  
  def save_settings
    current_user.update(user_params)
    @subscription = Subscription.where(:email => current_user.email).first
    @subscription.update(subscription_params)
    #redirect_to '/dashboard'
    render text: 'ok'
  end
  
    private
      def user_params
        params.require(:user).permit(:email, :name)
      end
      
      def subscription_params
        return {
          :notify_daily_results => (params[:notify_daily_results] == 'true'),
          :notify_personal_num_info => (params[:notify_personal_num_info] == 'true')
        }
      end
      
end
