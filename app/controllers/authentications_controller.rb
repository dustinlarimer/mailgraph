class AuthenticationsController < ApplicationController
  def index
    @authentications = current_user.authentications if current_user
    #Authentication.first.destroy
    #render :text => current_user.id
    #render :text => Authentication.find(:first, "provider: google AND uid: dustinlarimer@gmail.com").user_id.to_yaml
    #render :text => Authentication.find(:first, :conditions => {:provider => 'google', :uid => 'dustinlarimer@gmail.com'}).incoming(:user).to_yaml
  end
  
  def create
    callback = request.env['omniauth.auth']
    #owner = User.find(:email => callback['info']['email'])
    #owner_auth = owner.outgoing(:authentications).find{|node| node[:provider] == callback['provider'] && node[:uid] == callback['uid']}
    #render :text => owner_auth.to_yaml
    
    ### CROSS-CHECK AUTHENTICATION MODEL
    auth = Authentication.find(:first, :conditions => {:provider => callback['provider'], :uid => callback['uid']})
    
    if auth
      #render :text => auth.user_id.to_yaml
      /### Sign in with auth.user_id/
      user = User.find(auth.user_id)
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, user)
    elsif current_user
      #render :text => current_user.id
      /### Create new Authentication/
      Neo4j::Transaction.run do
        ###new_auth = Neo4j::Node.new!()
        new_auth = Authentication.create(:user_id => current_user.id, :provider => callback['provider'], :uid => callback['uid'])
        current_user.authentications << new_auth
        current_user.save
      end
      flash[:notice] = "Authentication successful."
      redirect_to authentications_url
      
    else
      render :text => "Else!"
      /### Register new User
      new_user = User.new
      new_user.apply_omniauth(callback)
      if new_user.save
        flash[:notice] = "Account created and authenticated successfully."
        sign_in_and_redirect(:user, new_user)
      else
        #session[:omniauth] = callback.except('extra')
        #redirect_to new_user_registration_url
      end
      /
    end
    
    /
    if owner_auth 
      # User exists and has already authenticated with this provider
      flash[:notice] = "Signed in successfully."
      #render :text => owner_auth.to_yaml
      sign_in_and_redirect(:user, owner)
      
    elsif current_user
      #render :text => 'Elsif'
      Authentication.create(:user_id => current_user.id, :provider => callback['provider'], :uid => callback['uid'])
      #current_user.authentications.create!(:provider => callback['provider'], :uid => callback['uid'])
      render :text => Authentication.first.to_yaml
      #redirect_to authentications_url
    else
      render :text => 'Else'
      # Create a new user
    end
    /
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