class LinkDoc
  require 'open-uri'
  
  attr_reader :link_url, :link_doc, :link_doc_desc, :link_doc_error,
              :image_url, :image_height, :image_width, 
              :video_url, :video_height, :video_width
  
  def initialize(link_url)
    begin
      @link_doc = Nokogiri::HTML(open(URI.encode(link_url)))
    rescue Timeout::Error
      @link_doc_error = "timeout error on one of the links: #{link_url}"
    rescue OpenURI::HTTPError
      @link_doc_error = "bad link: #{link_url}"
    rescue Errno::ETIMEDOUT
      @link_doc_error =  "timeout: #{link_url}"
    rescue RuntimeError
      @link_doc_error =  "runtime error: #{link_url}"
    rescue URI::InvalidURIError
      @link_doc_error =  "invalid uri error: #{link_url}"
    end
    
    #logger.debug link_doc
    unless @link_doc.nil?
      # images
      # huffpo 
      @image_url = @link_doc.at_xpath('//*[(@id = "potd_block")]//img')
      @image_url = @link_doc.at_xpath('//*[(@id = "entry_12345")]//img') if @image_url.nil?
  
      # ?
      @image_url = @link_doc.at_xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "asset", " " ))]') if @image_url.nil?
      # cnn
      @image_url = @link_doc.at_xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "cnn_strylccimg300cntr", " " ))]//img') if @image_url.nil?
      @image_url = @link_doc.at_xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "cnn_stryimg640captioned", " " ))]//img') if @image_url.nil?
  
      #hrc
      @image_url = @link_doc.at_xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "size-large", " " ))]') if @image_url.nil?
      @image_url = @link_doc.at_xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "size-medium", " " ))]') if @image_url.nil?
      @image_url = @link_doc.at_xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "size-full", " " ))]') if @image_url.nil?
  
      # out
      @image_url = @link_doc.at_xpath('//*[(@id = "column2detail")]//img') if @image_url.nil?
      
      #tumblr
      @image_url = @link_doc.at_xpath('//*[(@id = "postContent")]//img') if @image_url.nil?
      
      #logger.debug link_image.inspect
      
      unless @image_url.nil?
        @image_width = @image_url["width"] if @image_url.key?("width")
        @image_height = @image_url["height"] if @image_url.key?("height") 
      end
  
      # video
      link_object_video = @link_doc.at_xpath('//object')
      link_embed_video = @link_doc.at_xpath('//embed')
      
      @video_url = link_object_video unless link_object_video.nil?
      @video_url = link_embed_video if link_object_video.nil?
      
      unless @video_url.nil?
        @video_width = video_url["width"] if video_url.key?("width")
        @video_height = video_url["height"] if video_url.key?("height") 
      end
      
      # content description
      @link_desc = @link_doc.at_css('.entry-body p')
      @link_desc = @link_doc.at_css('.entry_body_text p') if @link_desc.nil?
      #logger.debug link_desc.inspect
      @link_desc = @link_desc.children[0] unless @link_desc.nil?
    end
  end
  
end