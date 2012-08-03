class AuthenticationsController < ApplicationController
  def index
    @authentications = current_user.authentications if current_user
  end
  
  def create
    callback = request.env["omniauth.auth"]
    conditions = { :provider => callback['provider'], :uid => callback['uid'] }
    #auth = Authentication.find_by_provider_and_uid(callback['provider'], callback['uid'])
    #auth = Authentication.find(:first, :conditions => conditions)# || Authentication.create(conditions)
    auth = Authentication.find(:first, :conditions => conditions)
    if auth
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, auth.user)
    elsif current_user
      current_user.authentications.create!(:provider => callback['provider'], :uid => callback['uid'])
      flash[:notice] = "Authentication successful."
      redirect_to authentications_url
    else
      user = User.new
      user.apply_omniauth(callback)
      if user.save
        flash[:notice] = "Signed in successfully."
        sign_in_and_redirect(:user, user)
      else
        session[:omniauth] = callback.except('extra')
        redirect_to new_user_registration_url
      end
    end
    
  end
  
  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to authentications_url
  end
end