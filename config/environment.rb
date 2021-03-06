# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  
  config.gem "sqlite3-ruby", :lib => "sqlite3"
  config.gem "twitter"
  config.gem "nokogiri"
  config.gem "feedzirra"

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

end

TWITTER_CONFIG = YAML.load(File.read(Rails.root + 'config' + 'twitter.yml'))