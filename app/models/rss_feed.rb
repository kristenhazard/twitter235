class RssFeed < ActiveRecord::Base
  
  has_many :FeedEntries
  
end
