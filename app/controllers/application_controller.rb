class ApplicationController < ActionController::Base
  before_filter :authenticate
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def current_user
    #@_current_user ||= session[:fb_user_id] &&
    #  FbUser.find_by(fb_id: session[:fb_user_id])
    current_oauth_user ? FbUser.find_by(fb_id: current_oauth_user.uid) : nil
  end
  
  private
  def authenticate
    if !current_oauth_user.present?
      redirect_to root_path
    end
  end
end
