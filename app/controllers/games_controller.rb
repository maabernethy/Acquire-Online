class GamesController < ApplicationController
  # respond_to :json

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
        @game.start_game
        redirect_to game_path(@game)
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
    @cell = params[:cell]
    respond_to do |format|
      format.html { render :show}
      format.json do
        render :json => {
          :isCurrentPlayersTurn => @game.is_current_players_turn?(current_user.username),
          :playerHand => @game.player_hand(current_user),
          :test => @game.test(@cell)
        }
      end
    end
  end

  private

  def game_params
    params.require(:game).permit(:bank, :up_next, :name, {:user_ids => []})
  end
end
