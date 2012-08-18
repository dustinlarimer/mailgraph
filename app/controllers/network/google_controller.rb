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
      gmail.mailbox('[Gmail]/All Mail').find(:after => Date.parse("2012-08-16")).each do |email|
        from = "#{email.envelope.from[0].mailbox}@#{email.envelope.from[0].host}"
        if from == first.uid
          puts "From: ME!"
        else
          puts "From: #{from}"
        end
        
        
        to = email.envelope.to
        #puts "Sent to #{to.count} people:"
        to.each do |person|
          puts "»  to: #{person.mailbox}@#{person.host}"
        end
        
        cc = email.envelope.cc
        if cc
          #puts "CC'd #{cc.count} people:"
          cc.each do |person|
            puts "»  cc: #{person.mailbox}@#{person.host}"
          end
        end
        puts "--------------------"
        puts ""
      end
      
      #render :text => gmail.mailbox('[Gmail]/All Mail').find(:after => Date.parse("2012-08-08")).first.to_yaml
      
      #render :text => gmail.mailbox('[Gmail]/All Mail').find(:after => Date.parse("2012-08-08")).count
      gmail.logout
    end
  end
  
  def create
    render :text => "Analyze communications from the past 45 days"
  end
  
  def update
    render :text => "Analyze communications since last update"
  end
  
  def destroy
    render :text => "Destroy the whole pile"
  end
  
end
