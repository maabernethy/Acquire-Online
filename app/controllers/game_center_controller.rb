class GameCenterController < ApplicationController
  def show
    @users = User.all
    @no_friends = false
    count = 0
    @users.each do |user|
      if user.online?
        count = count + 1
      end
    end
    if count == 1
      @no_friends = true
    end
    @games = current_user.games
    @notifications = current_user.notifications
  end
end
