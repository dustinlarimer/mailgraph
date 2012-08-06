#require 'openssl'
#require 'net/https'
require 'net/smtp'
#require 'net/imap'
#require 'gmail'
require 'gmail_xoauth'

class AuthenticationsController < ApplicationController
  def index
    @authentications = current_user.authentications if current_user
    if current_user
      test = current_user.authentications.first
      /smtp = Net::SMTP.new('smtp.gmail.com', 587)
      smtp.enable_starttls_auto
      secret = {
        :consumer_key => 'anonymous',
        :consumer_secret => 'anonymous',
        :token => test.token,
        :token_secret => test.secret
      }
      smtp.start('gmail.com', test.uid, secret, :xoauth)
      render :text => smtp.to_yaml
      smtp.finish/
    end
  end
  
  def create
    callback = request.env['omniauth.auth']
    auth = Authentication.find(:first, :conditions => {:provider => callback['provider'], :uid => callback['uid']})
    if auth
      # Sign in with auth.user_id
      user = User.find(auth.user_id)
      auth.token = callback['credentials']['token']
      auth.secret = callback['credentials']['secret']
      auth.save
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, user)
    elsif current_user
      # Create new Authentication
      Neo4j::Transaction.run do
        new_auth = Authentication.create!(:user_id => current_user.id, :provider => callback['provider'], :uid => callback['uid'], :token => callback['credentials']['token'], :secret => callback['credentials']['secret'])
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