class Authentication < Neo4j::Rails::Model
  has_one :user #().from(User, :authentications)
  #accepts_id_for :user
  
  attr_accessible :user_id, :provider, :uid, :token, :secret
  
  property :user_id, :type => Fixnum
  property :provider, :type => String
  property :uid, :type => String
  property :token, :type => String
  property :secret, :type => String
  
  index :user_id
  index :provider
  index :uid
  
  def provider_name
    if provider == 'open_id'
      "OpenID"
    else
      provider.titleize
    end
  end
end
