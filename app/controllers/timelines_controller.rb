class TimelinesController < ApplicationController
  require 'open-uri'
  def index
    user = User.find(params[:user_id])
    session[:screen_name] = user.tw_screen_name
    client = user.tw_client
    @tweets = client.friends_timeline
    #logger.debug @tweets.to_yaml
    @tweets.each do |tweet|
      link_url = tweet.entities.urls[0].url if tweet.entities
      link_doc = Nokogiri::HTML(open(link_url))
      
      # images
      #link_first_image = link_doc.at_xpath('//img')
      #link_first_image = link_doc.at_xpath('//#potd_block img')
      # huffpo 
      link_first_image = link_doc.at_xpath('//*[(@id = "potd_block")]//img')
      #link_first_video = link_doc.at_xpath('//*[(@id = "entry_12345")]//center')
      # ?
      link_second_image = link_doc.at_xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "asset", " " ))]')
      # cnn
      link_third_image = link_doc.at_xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "cnn_strylccimg300cntr", " " ))]//img')
      
      # video
      link_object_video = link_doc.at_xpath('//object')
      link_embed_video = link_doc.at_xpath('//embed')
      
      tweet.link_first_image = link_first_image
      tweet.link_second_image = link_second_image
      tweet.link_third_image = link_third_image
      
      #tweet.link_first_video = link_first_video
      tweet.link_object_video = link_object_video
      tweet.link_embed_video = link_embed_video
      
      #logger.debug link_doc
      
    end
  end
end