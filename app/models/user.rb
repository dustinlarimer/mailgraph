class User < Neo4j::Rails::Model
  after_save :clean_authentications #, :if => session[:omniauth].nil?
  
  has_n :authentications #().to(Authentication)
  has_n :friends
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :id, :email, :password, :password_confirmation, :remember_me
  
  property :email, :type => String, :unique => true
  property :name, :type => String
  
  index :id
  index :email
  index :name
  
  #accepts_nested_attributes_for :authentications, :allow_destroy => true
  
  def apply_omniauth(callback)
    self.email = callback['info']['email'] if email.blank?
    Neo4j::Transaction.run do
      authentications << Authentication.create!(:provider => callback['provider'], :uid => callback['uid'], :token => callback['credentials']['token'], :secret => callback['credentials']['secret'])
    end
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end
  
  def clean_authentications
    authentications.each do |auth|
      auth.user_id = self.id
      auth.save
    end
    #render :text => self.id
  end
end
