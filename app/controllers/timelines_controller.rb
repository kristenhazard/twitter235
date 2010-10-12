class TimelinesController < ApplicationController
  require 'open-uri'
  def index
    @user = User.find(params[:user_id])
    session[:screen_name] = @user.tw_screen_name
    client = @user.tw_client
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
  
  # these don't work yet, need to update reference to client based on user feed
  def favorites
    params[:page] ||= 1
    @favorites = client.favorites(:page => params[:page])
  end

  def create
    @user = User.find_by_tw_screen_name(session[:screen_name])
    logger.debug @user.to_yaml
    client = @user.tw_client
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