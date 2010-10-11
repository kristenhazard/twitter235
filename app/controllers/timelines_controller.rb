class TimelinesController < ApplicationController
  require 'open-uri'
  def index
    user = User.find(params[:user_id])
    session[:screen_name] = user.tw_screen_name
    client = user.tw_client
    @tweets = client.friends_timeline
    #logger.debug @tweets.to_yaml
    @tweets.each do |tweet|
        link_url = tweet.entities.urls[0].url if tweet.entities.urls[0]
        if link_url
        begin
          link_doc = Nokogiri::HTML(open(URI.encode(link_url)))
        rescue Timeout::Error
          flash[:notice] = "timeout error on one of the links"
        end
        logger.debug link_doc
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
        
        # video
        link_object_video = link_doc.at_xpath('//object')
        link_embed_video = link_doc.at_xpath('//embed')
      
        # set tweet attributes
        tweet.link_image = link_image
        tweet.link_video = link_object_video unless link_object_video.nil?
        tweet.link_video = link_embed_video if link_object_video.nil?
      
        
      end
    end
  end
end