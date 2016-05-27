class UserController < ApplicationController  
  def settings     
  end
  
  def save_settings
    current_user.update(user_params)
    redirect_to '/dashboard'
  end
  
    private
      def user_params
        params.require(:user).permit(:email, :name)
      end
end
