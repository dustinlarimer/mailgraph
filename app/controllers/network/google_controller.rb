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
      gmail.mailbox('[Gmail]/All Mail').find(:after => Date.parse("2012-08-19")).each do |email|
        from = "#{email.envelope.from[0].mailbox}@#{email.envelope.from[0].host}"
        #if current_user.authentications.any?{ |authentication| authentication.uid == from }
        if auth_of_current_user(from)
          puts "From: <SELF>"
        else
          puts "From: #{from}"
        end
                
        to = email.envelope.to
        #puts "Sent to #{to.count} people:"
        to.each do |person|
          to_email = "#{person.mailbox}@#{person.host}"
          if current_user.authentications.any?{ |authentication| authentication.uid == to_email }
            puts "»  to: <SELF>"
          else
            to_contact = Contact.find_or_create_by(:email => to_email)
            if current_user.contacts.any?{ |contact| contact == to_contact }
              # Exists, do nothing
              puts "»  to: #{to_contact.email}, (Exists)"
            else
              # Add to User
              current_user.contacts << to_contact
              current_user.save
              puts "»  to: #{to_contact.email}, (New: #{current_user.contacts.count})"
            end
          end
        end
        
        cc = email.envelope.cc
        if cc
          #puts "CC'd #{cc.count} people:"
          cc.each do |person|
            cc_email = "#{person.mailbox}@#{person.host}"
            if current_user.authentications.any?{ |authentication| authentication.uid == cc_email }
              puts "»  cc: <SELF>"
            else
              cc_contact = Contact.find_or_create_by(:email => cc_email)
              if current_user.contacts.any?{ |contact| contact == cc_contact }
                # Exists, do nothing
                puts "»  cc: #{cc_contact.email}, (Exists)"
              else
                # Add to User
                current_user.contacts << cc_contact
                current_user.save
                puts "»  cc: #{cc_contact.email}, (New: #{current_user.contacts.count})"
              end
            end
            #current_user.contacts.find_or_create_by_email('#{person.mailbox}@#{person.host}')
            #puts "»  cc: "
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
