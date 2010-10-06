class TimelinesController < ApplicationController
  def index
    user = User.find(params[:user_id])
    session[:screen_name] = user.tw_screen_name
    client = user.tw_client
    @tweets = client.friends_timeline
  end
end