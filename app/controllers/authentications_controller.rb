class AuthenticationsController < ApplicationController
  
  def index
    @authentications = current_user.authentications if current_user
    @mailboxes = current_user.mailboxes if current_user
    respond_to do |format|
      format.html
      #format.json { render :json => @mailboxes.first.messages.to_json(:include=>[:from, :to, :cc]) }
      #format.json { render :json => @mailboxes.to_json(:include=>{:messages => {:include => [:from, :to, :cc]}}) }
      format.json { render :json => custom_json_for(@mailboxes) }
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
        
        #mailbox = Mailbox.find(:first, :conditions => {:email => callback['uid']})
        mailbox = Mailbox.find_or_create_by(:email => callback['uid'])
        if mailbox.user_id.nil? 
          mailbox.user_id = current_user.id
          mailbox.save
          current_user.mailboxes << mailbox
          #else
          #new_mailbox = Mailbox.create!(:user_id => current_user.id, :email => callback['uid'])
          #current_user.mailboxes << Mailbox.create!(:user_id => current_user.id, :email => callback['uid'])
        end
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
  
  private
  def custom_json_for(value)
    #value.to_json(:include=>{:messages => {:include => [:from, :to, :cc]}})
    nodes = Array.new
    links = Array.new
    wrapper = { "nodes" => nodes, "links" => links }
    mailboxes = value.map do |mailbox|
      
      ties = Array.new
      hash = Hash.new(0)
      
      mailbox.messages.each_with_index do |message, i|
        #break if i == 50;
        entities = Array.new
        from = message.from
        to = message.to.to_ary | message.cc.to_ary
        
        entities.push(from).concat(to)
        entities.each do |contact|
          node = { :email => contact.email, :mailbox_id => contact.id.to_i, :freq => 1 }
          if nodes.detect { |el| el[:email] == contact.email } #nodes.index(node).nil?
            find_dup = nodes.detect { |el| el[:email] == contact.email }
            find_dup[:freq] += 1
            puts "#{find_dup[:email]} tracked #{find_dup[:freq]} times"
          else
            nodes << node
          end
        end
        
        from_source = nodes.detect { |el| el[:email] == from.email }
        from_index = nodes.index(from_source)
        to.each do |target|
          to_source = nodes.detect { |el| el[:email] == target.email }
          to_index = nodes.index(to_source)
          tie = { :source => from_index, :target => to_index }
          if from_source[:freq] > 0
            ties << tie
          end
        end
        
      end
      
      ties.each do |tie|
        hash[tie] += 1
      end
      hash.each do |k, v|
        link = { :source => k[:source], :target => k[:target].to_i, :value => v }
        links << link
      end
      
    end
    
    wrapper.to_json
  end
  
end