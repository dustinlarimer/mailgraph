class Authentication < Neo4j::Rails::Model
  has_one(:user).to(User)
  accepts_id_for :user
  
  attr_accessible :provider, :uid
  #property :user_id, :type => Fixnum
  property :provider, :type => String
  property :uid, :type => String
  
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
