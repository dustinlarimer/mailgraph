class Mailbox < Neo4j::Rails::Model
  has_one :user
  #has_one :authentication
  has_n(:messages).to(Message)
  
  attr_accessible :user_id, :email
  
  property :user_id, :type => Fixnum
  property :email, :type => String
  
  index :user_id
  index :email
end
