#require 'openssl'
#require 'net/https'
#require 'net/smtp'
#require 'net/imap'
#require 'net/imap'
#require 'oauth'
require 'gmail'
#require 'gmail_xoauth'
require 'mail'

class AuthenticationsController < ApplicationController
  def index
    @authentications = current_user.authentications if current_user
    if current_user
      test = current_user.authentications.first
      gmail = Gmail.connect!(:xoauth, test.uid, 
        :token           => test.token,
        :secret          => test.secret,
        :consumer_key    => 'anonymous',
        :consumer_secret => 'anonymous'
      )
      #render :text => gmail.mailbox('[Gmail]/All Mail').count #.to_yaml #mailbox('').count
      @mailcount = gmail.mailbox('[Gmail]/All Mail').count
      gmail.logout
      #Mail.defaults do
      #  retriever_method :pop3, :address    => "pop.gmail.com",
      #                          :port       => 995,
      #                          :user_name  => test.uid,
      #                          :password   => test.token,
      #                          :enable_ssl => true
      #end
      #emails = Mail.find(:what => :first, :count => 10, :order => :asc)
      #render :text => emails.length
    end
  end
  
  def create
    callback = request.env['omniauth.auth']
    #render :text => callback.to_yaml
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