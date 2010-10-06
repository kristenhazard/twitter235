ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'timelines'
  map.resources :users, :member => { :authorize_twitter => :get }
  map.resource :session
  map.resources :timelines
  map.finalize_session 'session/finalize', :controller => 'sessions', :action => 'finalize'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.finalize_twitter 'user/finalize', :controller => 'users', :action => 'finalize'
  #map.oauth_callback '/oauth_callback', :controllber => 'sessions', :action => 'oauth_callback'

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
