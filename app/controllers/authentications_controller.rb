class AuthenticationsController < ApplicationController
  def index
    @authentications = current_user.authentications if current_user
  end
  
  def create
    callback = request.env['omniauth.auth']
    owner = User.find(:email => callback['info']['email'])
    owner_auth = owner.outgoing(:authentications).find{|node| node[:provider] == callback['provider'] && node[:uid] == callback['uid']}
    #render :text => owner_auth.to_yaml

    if owner_auth 
      # User exists and has already authenticated with this provider
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, owner)
      
    elsif current_user
      render :text => 'Elsif'
      #current_user.authentications.create!(:provider => callback['provider'], :uid => callback['uid'])
      
    else
      render :text => 'Else'
      # Create a new user
      
    end
    
    /
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
    /
  end
  
  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to authentications_url
  end
end