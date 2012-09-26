class Mailbox < Neo4j::Rails::Model
  has_one :user
  #has_one :authentication
  has_n(:messages).to(Message)
  
  attr_accessible :user_id, :email, :last_update
  
  property :user_id, :type => Fixnum, :index => :exact
  property :email, :type => String, :index => :exact
  property :last_update, :type => DateTime, :index => :exact
end
