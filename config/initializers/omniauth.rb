### Restart server after changing this file
# require 'openid/store/filesystem'
  ### If you get "openid/store/filesystem (LoadError)" then you may need to add this to your Gemfile:
  # > gem "oa-openid"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google, 'anonymous', 'anonymous', :scope => 'https://mail.google.com/mail/feed/atom/' #CONSUMER_KEY, CONSUMER_SECRET
  #provider :openid, OpenID::Store::Filesystem.new('./tmp'), :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'   
  #provider :facebook, 'APP_ID', 'APP_SECRET'
  #provider :twitter, 'CONSUMER_KEY', 'CONSUMER_SECRET'
  #provider :github, 'CLIENT ID', 'SECRET'
end