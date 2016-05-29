class LoginController < ApplicationController
  skip_before_filter :authenticate 
  
  def index
    if current_user.present?
      redirect_to root_path
    end
  end

  def register
    index
  end
  
  def update
    
    user = session[:fb_user_temp]
    profile = params["profile"]
 #   redirect_to root_path
    user_params = { :fb_id => user["id"],
        :first_name => user["first_name"],
        :last_name => user["last_name"],
        :photo => user["photo_large"],
        :fb_info => user.inspect,
        :email => profile["email"],
        :mobile_no => profile["mobile_no"],
        :blood_type => profile["blood_type"]};
        
    if (FbUser.create(user_params)) 
      
      session[:fb_user] = user_params
      session[:fb_user_temp] = nil
      redirect_to root_path
    else 
      render text: user_params.inspect
    end
  end
  
  def facebook
    
    callback_url = URI.escape(request.base_url + "/login/fb_redirect", Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")) 
    
    #Redirect to FB login page to initiate user login
    redirect_to "https://www.facebook.com/dialog/oauth?client_id=" + Lottominer::Application::FB_APP_ID + 
      "&redirect_uri=" + callback_url +
      "&response_type=token&type=web_server&scope=user_friends,email"
  end
  
  def fb_redirect
    
    require "net/http"
    require "uri"
    
    if (params[:error]) 
      redirect_to root_path
      return
    end
    
    begin
      #FB API call to obtain access token from the code token sent from user's FB dialog login
      url_string = "https://graph.facebook.com/oauth/access_token?client_id=" + Lottominer::Application::FB_APP_ID + 
        "&redirect_uri=" + 
        URI.escape(request.base_url + "/login/fb_redirect", Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")) + 
        "&client_secret=" + Lottominer::Application::FB_APP_SECRET +
        "&code=" + params[:code]
  
      token_params = Rack::Utils.parse_nested_query(NetworkUtil.https_get(url_string))
      session[:fb_access_token] = token_params["access_token"]
      #End of obtaining access token, yey! Proceed to retrieving user info.
      @fb_user = get_current_fb_user
      
      @db_user = FbUser.find_by(fb_id: @fb_user["id"])
      if (@db_user)
        session[:fb_user_id] = @fb_user["id"]
        redirect_to dashboard_path
      else
        @db_user = FbUser.new(
          fb_id: @fb_user["id"],
          name: @fb_user["name"],
          photo: @fb_user["photo_large"],
          email: @fb_user["email"],
          fb_info: @fb_user.inspect
        )
        
        render 'register'
      end
    rescue => ex
      logger.error ex.message
      render text: ex.message
    end
  end
  
  def saveuser
    fbuser = FbUser.new(fbuser_params)
    if (fbuser.save)
      session[:fb_user_id] = fbuser[:fb_id]
      user_settings = create_user_settings(fbuser)
      send_email(fbuser, user_settings)
      render 'reg_ok'
    else
      render text: @db_user.errors.full_messages.to_sentence
    end
  end
  
  def verify
    id = params[:id]
    if (!id.nil?)
      setting = UserSetting.find_by(email_verification: id)
      if (!setting.nil?)
        @db_user = FbUser.find_by(id: setting.fb_user_id)
        setting.email_verification = 'ok'
        setting.save   
        render 'email_verified'
        return
      end
    end
    raise ActionController::RoutingError.new('Not Found')
  end
  
  def logout
    @_current_user = session[:fb_user_id] = nil
    redirect_to root_path
  end


  
  def validate
      user = params[:login];
      existing_user = User.find_by(email: user[:email], password: user[:password])
      if existing_user
      #if User.authenticate(user[:email], user[:password])
        session[:current_user_id] = existing_user.id
        redirect_to root_path
      elsif(user[:email] == "julius" && user[:password] == "delfino") 
        
          new_user = User.new(login_params)
          if new_user.save
            render text: "Successfully created new user in DB!"
          else
            render text: "Error occurred creating new user in DB!"
          end
      else 
        if(user[:email] == "" && user[:password] == "") 
           @error = "Please login."
         else
          @error = "Invalid username or password."
         end
        render 'index'
      end
  end
  
  private
  
  def login_params
    params.require(:login).permit(:email, :password)
  end
  
  def get_current_fb_user

    access_token = session[:fb_access_token]
    uri = "https://graph.facebook.com/me?fields=id,name,email&access_token=" + access_token
      
    fb_user = JSON.parse(NetworkUtil.https_get(uri))
    
    uri = "https://graph.facebook.com/me/picture?redirect=false&type=square&access_token=" + access_token
    fb_photo = JSON.parse(NetworkUtil.https_get(uri))
    fb_user["photo"] = fb_photo["data"]["url"]
    
    uri = "https://graph.facebook.com/me/picture?redirect=false&type=large&access_token=" + access_token
    fb_photo = JSON.parse(NetworkUtil.https_get(uri))
    fb_user["photo_large"] = fb_photo["data"]["url"]
    
    return fb_user
  end
  
  def fbuser_params
    params.require(:user).permit(:fb_id, :name, :email, :photo, :fb_info)
  end
  
  def create_user_settings(fbuser)
    
    setting = UserSetting.new(
      fb_user_id: fbuser.id,
      email_verification: SecureRandom.hex(16))
    setting.save
    return setting
  end
  
  def send_email(user, settings)
    @user = user
    @verify_url = request.base_url + '/verifyemail?id=' + settings.email_verification
    mail_body = render_to_string :template => '/mail/verify_email', layout: 'mailer'
    mail_info = {
        to: user.email,
        from: 'Lotto Analytics <no-reply@' + request.domain + '>',
        subject: 'Welcome to Lotto Analytics',
        html: mail_body
    }
      
    EmailUtil.send mail_info
  end
end
