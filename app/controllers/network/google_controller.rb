require 'gmail'
class Network::GoogleController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    if current_user && current_user.authentications.count > 0
      first = current_user.authentications.first
      gmail = Gmail.connect!(:xoauth, first.uid, 
        :token           => first.token,
        :secret          => first.secret,
        :consumer_key    => 'anonymous',
        :consumer_secret => 'anonymous'
      )
      render :text => gmail.mailbox('[Gmail]/All Mail').count
      #@mailcount = gmail.mailbox('[Gmail]/All Mail').count
      gmail.logout
    end
  end
  
  def create
  end
  
  def update
  end
  
  def destroy
  end
  
end
