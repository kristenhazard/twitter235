class TwitterFeed < ActiveRecord::Base
  def tw_authorized?
    tw_token.present? && tw_secret.present?
  end
  
  def oauth
    @oauth ||= Twitter::OAuth.new(TWITTER_CONFIG['oauth_consumer_key'], TWITTER_CONFIG['oauth_consumer_secret'])
  end
  
  delegate :request_token, :access_token, :authorize_from_request, :to => :oauth
  
  def tw_client
    @client ||= begin
      oauth.authorize_from_access(tw_token, tw_secret)
      Twitter::Base.new(oauth)
    end
  end
end
