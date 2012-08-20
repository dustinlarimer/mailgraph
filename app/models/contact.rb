class Contact < Neo4j::Rails::Model
  has_one :user
  property :email, :type => String, :unique => true
  index :email
end
