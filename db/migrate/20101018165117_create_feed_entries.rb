class CreateFeedEntries < ActiveRecord::Migration
  def self.up
    create_table :feed_entries do |t|
      t.string :name
      t.text :summary
      t.string :url
      t.datetime :published_at
      t.string :guid
      t.string :image_url
      t.integer :image_width
      t.integer :image_height
      t.string :video_url
      t.integer :video_width
      t.integer :video_height
      t.integer :rss_feed_id

      t.timestamps
    end
  end

  def self.down
    drop_table :feed_entries
  end
end
