class GameCenterController < ApplicationController
  def show
    @users = User.all
  end
end
