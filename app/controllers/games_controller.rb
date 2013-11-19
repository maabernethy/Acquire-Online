class GamesController < ApplicationController
  def new
    @game = Game.new
    @users_online = []
    User.all.each do |user|
      if (user.online?) && (user != current_user)
         @users_online << user
      end
    end
  end

  def create
    @game = Game.new(game_params)
    @game.users << current_user
    if (@game.users.size >= 3) && (@game.users.size <= 6)
      if @game.save
        render :show
      else
        render :new
      end
    else
      flash[:error] = 'A game must be between 3 and 6 players'
      render :new
    end
  end

  def show
    @game = Game.find(params[:id])
    @game.start_game
    # @players = @game.users
  end

  private

  def game_params
    params.require(:game).permit(:name, {:user_ids => []})
  end
end
