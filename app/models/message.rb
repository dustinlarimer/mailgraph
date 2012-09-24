class Message < Neo4j::Rails::Model
  has_one(:mailbox).from(Mailbox, :messages)
  has_one(:from).to(Mailbox)
  has_n(:to).to(Mailbox)
  has_n(:cc).to(Mailbox)
  
  attr_accessible :message_id, :message_datetime
  
  property :message_id, :type => String, :index => :exact
  property :message_datetime, :type => DateTime, :index => :exact
  property :updated_at
  property :created_at, :index => :exact
  
  #index :message_id
  #index :message_datetime, :type => DateTime
end
