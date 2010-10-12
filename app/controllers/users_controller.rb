class UsersController < ApplicationController
  def index
    @users = User.all
  end
  
  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to(users_url) 
    else
      render :action => "new" 
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to(@user) 
    else
      render :action => "edit" 
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to(users_url) 
  end
  
  # twitter
  def authorize_twitter
    oauth.set_callback_url(finalize_twitter_url)
    
    session['rtoken']  = oauth.request_token.token
    session['rsecret'] = oauth.request_token.secret
    user = User.find(params[:id])
    session['user_screen_name'] = user.tw_screen_name
    logger.debug session['user_screen_name']
    
    redirect_to oauth.request_token.authorize_url
  end
  
  def finalize
    oauth.authorize_from_request(session['rtoken'], session['rsecret'], params[:oauth_verifier])
    
    session['rtoken']  = nil
    session['rsecret'] = nil
    
    profile = Twitter::Base.new(oauth).verify_credentials
    logger.debug profile.screen_name
    requested_user_screen_name = session['user_screen_name']
    
    if profile.screen_name == requested_user_screen_name
      user = User.find_by_tw_screen_name(profile.screen_name)
    
      if user
        user.update_attributes({
          :tw_screen_name => profile.screen_name,
          :tw_token => oauth.access_token.token, 
          :tw_secret => oauth.access_token.secret,
        })
        flash[:notice] = "Success! Twitter was authorized for #{profile.screen_name} and mapped to #{user.tw_screen_name}."
      else
        flash[:notice] = "Twitter tried to authorize #{profile.screen_name} but that doesn't match a user in our system. This is caused by browser caching. Go to twitter.com and sign out."
      end
    else
      flash[:notice] = "Twitter tried to authorize #{profile.screen_name} but that doesn't match #{user.tw_screen_name}. This is caused by browser caching. Go to twitter.com and sign out."
    end
    redirect_to(users_url) 
  end
end
