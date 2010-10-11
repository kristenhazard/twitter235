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
        link_doc = Nokogiri::HTML(open(URI.encode(link_url)))
      
        # images
        #link_first_image = link_doc.at_xpath('//img')
        #link_first_image = link_doc.at_xpath('//#potd_block img')
        # huffpo 
        link_first_image = link_doc.at_xpath('//*[(@id = "potd_block")]//img')
        link_first_image = link_doc.at_xpath('//*[(@id = "entry_12345")]//img') if link_first_image.nil?
        
        #link_first_video = link_doc.at_xpath('//*[(@id = "entry_12345")]//center')
        # ?
        link_second_image = link_doc.at_xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "asset", " " ))]')
        # cnn
        link_third_image = link_doc.at_xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "cnn_strylccimg300cntr", " " ))]//img')
        link_third_image = link_doc.at_xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "cnn_stryimg640captioned", " " ))]//img') if link_third_image.nil?
        
        #hrc
        link_fourth_image = link_doc.at_xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "size-large", " " ))]')
        link_fourth_image = link_doc.at_xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "size-medium", " " ))]') if link_fourth_image.nil?
        link_fourth_image = link_doc.at_xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "size-full", " " ))]') if link_fourth_image.nil?
        
        # out
        link_fourth_image = link_doc.at_xpath('//*[(@id = "column2detail")]//img') if link_fourth_image.nil?
        
        # video
        link_object_video = link_doc.at_xpath('//object')
        link_embed_video = link_doc.at_xpath('//embed')
      
        tweet.link_first_image = link_first_image
        tweet.link_second_image = link_second_image
        tweet.link_third_image = link_third_image unless link_third_image.nil?
        tweet.link_third_image = link_fourth_image if link_third_image.nil?
      
        #tweet.link_first_video = link_first_video
      
      
        tweet.link_object_video = link_object_video unless link_object_video.nil?
        tweet.link_object_video = link_embed_video if link_object_video.nil?
      
        #logger.debug link_doc
      end
    end
  end
end