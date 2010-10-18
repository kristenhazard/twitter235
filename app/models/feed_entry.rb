class FeedEntry < ActiveRecord::Base
  
  belongs_to :RssFeed
  
  def self.update_from_feed(rss_feed)
    @rss_feed = rss_feed #do i need to set this instance variable or is it just set???
    feed = Feedzirra::Feed.fetch_and_parse(rss_feed.url)
    add_entries(feed.entries)
  end
  
  def self.update_from_feed_continuously(feed_url, delay_interval = 15.minutes)
    feed = Feedzirra::Feed.fetch_and_parse(feed_url)
    add_entries(feed.entries)
    loop do
      sleep delay_interval
      feed = Feedzirra::Feed.update(feed)
      add_entries(feed.new_entries) if feed.updated?
    end
  end
  
  private
  
  def self.add_entries(entries)
    entries.each do |entry|
      unless exists? :guid => entry.id
        link_url = entry.url
        unless link_url.nil?
          ld = LinkDoc.new(link_url)
          image_url = ld.image_url.to_html unless ld.image_url.nil?
          image_width = ld.image_width
          image_height = ld.image_height
          video_url = ld.video_url.to_html unless ld.video_url.nil?
          video_width = ld.video_width
          video_height = ld.video_height
          #flash[:notice] = ld.link_doc_error
        end
        create!(
          :name         => entry.title,
          :summary      => entry.summary,
          :url          => entry.url,
          :published_at => entry.published,
          :guid         => entry.id,
          :image_url    => image_url,
          :image_width  => image_width,
          :image_height => image_height,
          :video_url    => video_url,
          :video_width  => video_width,
          :video_height => video_height,
          :rss_feed_id  => @rss_feed.id
        )
      end
    end
  end
end
