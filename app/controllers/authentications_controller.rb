class AuthenticationsController < ApplicationController
  def index
    @authentications = current_user.authentications if current_user
    #Authentication.first.destroy
    #render :text => current_user.id
    #render :text => Authentication.find(:first, :conditions => {:provider => 'google', :uid => 'dustinlarimer@gmail.com'}).incoming(:user).to_yaml
    #render :text => Authentication.find(:first, "provider: google AND uid: dustinlarimer@gmail.com").user_id.to_yaml
  end
  
  def create
    callback = request.env['omniauth.auth']
    auth = Authentication.find(:first, :conditions => {:provider => callback['provider'], :uid => callback['uid']})    
    if auth
      # Sign in with auth.user_id
      user = User.find(auth.user_id)
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, user)
      
    elsif current_user
      # Create new Authentication
      Neo4j::Transaction.run do
        new_auth = Authentication.create!(:user_id => current_user.id, :provider => callback['provider'], :uid => callback['uid'])
        current_user.authentications << new_auth
        current_user.save
      end
      flash[:notice] = "Authentication successful."
      redirect_to authentications_url
      
    else
      # Register new User
      new_user = User.new
      new_user.apply_omniauth(callback)
      if new_user.save
        flash[:notice] = "Account created and authenticated successfully."
        sign_in_and_redirect(:user, new_user)
      else
        # Save to session and build Authentication later!
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