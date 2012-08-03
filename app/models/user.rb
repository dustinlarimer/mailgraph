class User < Neo4j::Rails::Model
  has_n :authentications
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  property :name, :type => String
  property :email, :type => String, :index => :exact
  has_n :friends
  
  def apply_omniauth(callback)
    self.email = callback['user_info']['email'] if email.blank?
    authentications.build(:provider => callback['provider'], :uid => callback['uid'])
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end
end
