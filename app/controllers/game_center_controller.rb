class GameCenterController < ApplicationController
  def show
    @users = User.all
    @games = current_user.games
  end
end
