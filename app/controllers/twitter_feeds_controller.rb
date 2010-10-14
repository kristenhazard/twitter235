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
        begin
          link_doc = Nokogiri::HTML(open(URI.encode(link_url)))
        rescue Timeout::Error
          flash[:notice] = "timeout error on one of the links: #{link_url}"
        rescue OpenURI::HTTPError
          flash[:notice] = "bad link: #{link_url}"
        rescue Errno::ETIMEDOUT
          flash[:notice] =  "timeout: #{link_url}"
        rescue RuntimeError
          flash[:notice] =  "runtime error: #{link_url}"
        end
        #logger.debug link_doc
        unless link_doc.nil?
          # images
          # huffpo 
          link_image = link_doc.at_xpath('//*[(@id = "potd_block")]//img')
          link_image = link_doc.at_xpath('//*[(@id = "entry_12345")]//img') if link_image.nil?
      
          # ?
          link_image = link_doc.at_xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "asset", " " ))]') if link_image.nil?
          # cnn
          link_image = link_doc.at_xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "cnn_strylccimg300cntr", " " ))]//img') if link_image.nil?
          link_image = link_doc.at_xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "cnn_stryimg640captioned", " " ))]//img') if link_image.nil?
      
          #hrc
          link_image = link_doc.at_xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "size-large", " " ))]') if link_image.nil?
          link_image = link_doc.at_xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "size-medium", " " ))]') if link_image.nil?
          link_image = link_doc.at_xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "size-full", " " ))]') if link_image.nil?
      
          # out
          link_image = link_doc.at_xpath('//*[(@id = "column2detail")]//img') if link_image.nil?
          
          #tumblr
          link_image = link_doc.at_xpath('//*[(@id = "postContent")]//img') if link_image.nil?
          
          
          # set tweet attributes
          tweet.link_image = link_image
          
          #logger.debug link_image.inspect
          
          unless link_image.nil?
            tweet.image_width = link_image["width"] if link_image.key?("width")
            tweet.image_height = link_image["height"] if link_image.key?("height") 
          end
      
          # video
          link_object_video = link_doc.at_xpath('//object')
          link_embed_video = link_doc.at_xpath('//embed')
          
          link_video = link_object_video unless link_object_video.nil?
          link_video = link_embed_video if link_object_video.nil?
          
          tweet.link_video = link_video
          
          unless link_video.nil?
            tweet.video_width = link_video["width"] if link_video.key?("width")
            tweet.video_height = link_video["height"] if link_video.key?("height") 
          end
          
          # content description
          link_desc = link_doc.at_css('.entry-body p')
          link_desc = link_doc.at_css('.entry_body_text p') if link_desc.nil?
          logger.debug link_desc.inspect
          tweet.link_desc = link_desc.children[0] unless link_desc.nil?
        end
      end
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
  
end