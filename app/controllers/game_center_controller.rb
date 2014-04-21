class GameCenterController < ApplicationController
  def show
    @users = User.all
    @games = current_user.games
    @notifications = current_user.notifications
  end
end
