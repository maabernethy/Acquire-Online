class GamesController < ApplicationController
  def new
    @game = Game.new
    @users_online = []
    User.all.each do |user|
      if user.online?
         @users_online.push(user.username)
      end
    end
  end

  def create
    @game = Game.new(game_params)
    if @game.save
      render :show
    else
      render :new
    end
  end

  def show
    @game = Game.find(params[:id])
  end

  private

  def game_params
    params.require(:game).permit(:name)
  end
end
