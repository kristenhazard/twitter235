class TimelinesController < ApplicationController
  def index
    user = User.find(params[:user_id])
    client = user.tw_client
    @tweets = client.friends_timeline
  end
end