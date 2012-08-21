class Contact < Neo4j::Rails::Model
  has_one :user
  
  attr_accessible :user_id, :email
  
  property :email, :type => String, :unique => true
  
  index :user_id
  index :email
end
