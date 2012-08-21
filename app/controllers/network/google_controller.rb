require 'gmail'
class Network::GoogleController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    if current_user && current_user.authentications.count > 0
      first = current_user.authentications.first
      mailbox = Mailbox.find(:first, :conditions => {:user_id => current_user.id, :email => first.uid})
      gmail = Gmail.connect!(:xoauth, first.uid, 
        :token           => first.token,
        :secret          => first.secret,
        :consumer_key    => 'anonymous',
        :consumer_secret => 'anonymous'
      )
      gmail.mailbox('[Gmail]/All Mail').find(:after => Date.parse("2012-08-14")).each do |email|
        
        if mailbox.messages.any?{ |message| message.message_id == email.envelope.message_id }
          puts "Message already logged! (#{mailbox.messages.count})"
        else
          from = "#{email.envelope.from[0].mailbox}@#{email.envelope.from[0].host}"
          from_mailbox = Mailbox.find_or_create_by(:email => from)
          to_mailboxes = Array.new
          cc_mailboxes = Array.new

          to = email.envelope.to
          if to
            to.each do |person|
              to_email = "#{person.mailbox}@#{person.host}"
              to_mailboxes << Mailbox.find_or_create_by(:email => to_email)
            end
          end
        
          cc = email.envelope.cc
          if cc
            cc.each do |person|
              cc_email = "#{person.mailbox}@#{person.host}"
              cc_mailboxes << Mailbox.find_or_create_by(:email => cc_email)
            end
          end
        
          Neo4j::Transaction.run do
            #puts "Message_ID: #{email.envelope.message_id}"
            new_message = mailbox.messages.build(:message_id => "#{email.envelope.message_id}", :message_datetime => "#{email.envelope.date}")
            new_message.from = from_mailbox
            new_message.to = to_mailboxes
            new_message.cc = cc_mailboxes
            new_message.save
            puts "From: #{new_message.from.email}; To: #{new_message.to.count}; Cc: #{new_message.cc.count}"
            puts "Messages pulled from this mailbox: #{mailbox.messages.count}"
          end
        
          puts "--------------------"
          puts ""
        end
      end
      
      #render :text => gmail.mailbox('[Gmail]/All Mail').find(:after => Date.parse("2012-08-08")).first.to_yaml
      #render :text => gmail.mailbox('[Gmail]/All Mail').find(:after => Date.parse("2012-08-08")).count
      gmail.logout
    end
  end
  
  def auth_of_current_user(address)
    if current_user.authentications.any?{ |authentication| authentication.uid == address }
      return true
    else
      return false
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
