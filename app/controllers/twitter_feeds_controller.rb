class TwitterFeedsController < ApplicationController
  
  require 'open-uri'
  
  def index
    @twitter_feeds = TwitterFeed.all
  end

  def show
    @twitter_feed = TwitterFeed.find(params[:id])
    session[:screen_name] = @twitter_feed.tw_screen_name
    client = @twitter_feed.tw_client
    @tweets = client.home_timeline
    #logger.debug @tweets.to_yaml
    @tweets.each do |tweet|
      link_url = tweet.entities.urls[0].url if tweet.entities.urls[0]
      unless link_url.nil?
        ld = LinkDoc.new(link_url)
        tweet.image_url = ld.image_url
        tweet.image_width = ld.image_width
        tweet.image_height = ld.image_height
        tweet.video_url = ld.video_url
        tweet.video_width = ld.video_width
        tweet.video_height = ld.video_height
        tweet.link_doc_desc = ld.link_doc_desc
        flash[:notice] = ld.link_doc_error
      end
    end
    
    respond_to do |format|
      format.html
      format.json { render :layout => false ,
                           :json => @tweets.to_json }
    end
  end

  def new
    @twitter_feed = TwitterFeed.new
  end

  def edit
    @twitter_feed = TwitterFeed.find(params[:id])
  end

  def create
    @twitter_feed = TwitterFeed.new(params[:twitter_feed])
    if @twitter_feed.save
      flash[:notice] = 'TwitterFeed was successfully created.'
      redirect_to(twitter_feeds_url) 
    else
      render :action => "new" 
    end
  end

  def update
    @twitter_feed = TwitterFeed.find(params[:id])
    if @twitter_feed.update_attributes(params[:twitter_feed])
      flash[:notice] = 'TwitterFeed was successfully updated.'
      redirect_to(twitter_feeds_url) 
    else
      render :action => "edit" 
    end
  end

  def destroy
    @twitter_feed = TwitterFeed.find(params[:id])
    @twitter_feed.destroy
    redirect_to(twitter_feeds_url) 
  end
  
# twitter
  def authorize
    oauth.set_callback_url(finalize_twitter_url)
    
    session['rtoken']  = oauth.request_token.token
    session['rsecret'] = oauth.request_token.secret
    twitter_feed = TwitterFeed.find(params[:id])
    session['tw_screen_name'] = twitter_feed.tw_screen_name
    logger.debug session['tw_screen_name']
    
    redirect_to oauth.request_token.authorize_url
  end
  
  def finalize
    oauth.authorize_from_request(session['rtoken'], session['rsecret'], params[:oauth_verifier])
    
    session['rtoken']  = nil
    session['rsecret'] = nil
    
    profile = Twitter::Base.new(oauth).verify_credentials
    logger.debug profile.screen_name
    requested_user_screen_name = session['tw_screen_name']
    
    if profile.screen_name == requested_user_screen_name
      twitter_feed = TwitterFeed.find_by_tw_screen_name(profile.screen_name)
    
      if twitter_feed
        twitter_feed.update_attributes({
          :tw_token => oauth.access_token.token, 
          :tw_secret => oauth.access_token.secret,
        })
        flash[:notice] = "Success! Twitter was authorized for #{profile.screen_name} and mapped to #{twitter_feed.tw_screen_name}."
      else
        flash[:notice] = "Twitter tried to authorize #{profile.screen_name} but that doesn't match a user in our system. This is caused by browser caching. Go to twitter.com and sign out."
      end
    else
      flash[:notice] = "Twitter tried to authorize #{profile.screen_name} but that doesn't match #{twitter_feed.tw_screen_name}. This is caused by browser caching. Go to twitter.com and sign out."
    end
    redirect_to(twitter_feeds_url) 
  end
  
  # these don't work yet, need to update reference to client based on user feed
  def favorites
    params[:page] ||= 1
    @favorites = client.favorites(:page => params[:page])
  end

  def create_tweet
    @twitter_feed = TwitterFeed.find(params[:id])
    logger.debug @twitter_feed.to_yaml
    client = @twitter_feed.tw_client
    logger.info client.inspect
    options = {}
    options.update(:in_reply_to_status_id => params[:in_reply_to_status_id]) if params[:in_reply_to_status_id].present?

    tweet = client.update(params[:text], options)
    flash[:notice] = "Got it! Tweet ##{tweet.id} created."
    return_to_or root_url
  end

  def fav
    flash[:notice] = "Tweet fav'd. May not show up right away due to API latency."
    client.favorite_create(params[:id])
    return_to_or root_url
  end

  def unfav
    flash[:notice] = "Tweet unfav'd. May not show up right away due to API latency."
    client.favorite_destroy(params[:id])
    return_to_or root_url
  end
  
end
