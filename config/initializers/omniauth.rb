# Restart server after changing this file
require 'openid/store/filesystem'
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, 'CONSUMER_KEY', 'CONSUMER_SECRET'
  provider :open_id, OpenID::Store::Filesystem.new('/tmp')
end

#Rails.application.config.middleware.use OmniAuth::Builder do  
  # you need a store for OpenID
  # use OmniAuth::Strategies::OpenID, OpenID::Store::Filesystem.new('/tmp') #, :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
  
  # If you get "openid/store/filesystem (LoadError)" then you may need to add this to your Gemfile:
  # > gem "oa-openid"  
  
  #provider :openid, OpenID::Store::Filesystem.new('./tmp'), :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'   
  #provider :facebook, 'APP_ID', 'APP_SECRET'
  #provider :twitter, 'CONSUMER_KEY', 'CONSUMER_SECRET'
  #provider :github, 'CLIENT ID', 'SECRET'
#end