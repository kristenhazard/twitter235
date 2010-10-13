ActionController::Routing::Routes.draw do |map|
  map.resources :rss_feeds

  map.root :controller => 'users'
  map.resources :timelines
  map.resources :users, :member => { :authorize_twitter => :get }
  map.finalize_twitter 'user/finalize', :controller => 'users', :action => 'finalize'

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
