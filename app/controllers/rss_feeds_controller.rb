class RssFeedsController < ApplicationController

  def index
    @rss_feeds = RssFeed.all
  end

  def show
    @rss_feed = RssFeed.find(params[:id])
    @feed = Feedzirra::Feed.fetch_and_parse(@rss_feed.url)
  end

  def new
    @rss_feed = RssFeed.new
  end

  # GET /rss_feeds/1/edit
  def edit
    @rss_feed = RssFeed.find(params[:id])
  end

  def create
    @rss_feed = RssFeed.new(params[:rss_feed])
      if @rss_feed.save
        flash[:notice] = 'RssFeed was successfully created.'
        redirect_to(@rss_feed) 
      else
        render :action => "new" 
      end
  end

  def update
    @rss_feed = RssFeed.find(params[:id])
      if @rss_feed.update_attributes(params[:rss_feed])
        flash[:notice] = 'RssFeed was successfully updated.'
        redirect_to(@rss_feed) 
      else
        render :action => "edit" 
      end
  end

  def destroy
    @rss_feed = RssFeed.find(params[:id])
    @rss_feed.destroy
    redirect_to(rss_feeds_url) 
  end
end
