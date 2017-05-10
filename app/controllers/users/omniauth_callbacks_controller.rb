class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :authenticate 
  
  def facebook
    @user = OauthUser.from_omniauth(request.env["omniauth.auth"])
    is_user_registered = false
    if @user.persisted?
      if (FbUser.find_by(fb_id: @user.uid).present?) 
        is_user_registered = true
        sign_in_and_redirect @user, :event => :authentication
        set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?        
      end
    end
    if !is_user_registered
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      @db_user = @user
      render '/login/register'
    end
  end

  def failure
    redirect_to root_path
  end
end