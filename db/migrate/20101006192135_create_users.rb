class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :tw_screen_name
      t.string :tw_token
      t.string :tw_secret

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
