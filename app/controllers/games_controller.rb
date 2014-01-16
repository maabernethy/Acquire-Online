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
    game = Game.find(params[:id])
    player = current_user.game_players.where(game: game).first
    tiles = player.tiles
    stocks = player.stock_cards_by_name_payload
    game_hotels = game.game_hotels
    hotels_by_name = []
    game_hotels.each do |hotel|
      hotels_by_name << {name: hotel.hotel.name, size: hotel.chain_size, price: hotel.share_price}
    end
    @payload = { game: game, users: game.users, tiles: tiles, player: player, stocks: stocks, game_hotels: hotels_by_name }
    byebug
  end

  def place_piece
    @cell = params[:cell]
    num, letter = params[:num].to_i, params[:letter]
    @game = Game.find(params[:id])
    @game_tile = @game.game_tiles.where(cell: @cell)
    @available_hotels = @game.game_hotels.where(chain_size: 0)
    player = current_user.game_players.where(game_id: @game.id).first
    # if @game.is_current_players_turn?(current_user)
    if true
      if @game.player_hand(current_user, @cell)
        available_tiles = @game.game_tiles.where(available: true)
        new_game_tile = available_tiles[rand(available_tiles.length)]
        new_game_tile.available = false
        new_game_tile.save
        new_tile = @game.tiles.where(id: new_game_tile.tile_id)
        placed_tile = player.tiles.where(row: letter).where(column: num).first
        placed_game_tile = @game.game_tiles.where(tile_id: placed_tile.id).first
        placed_game_tile.placed = true
        placed_game_tile.save
        player.tiles.delete(placed_tile)
        player.tiles << new_tile
        new_tiles = player.tiles.map {|tile| tile.to_english }

        array = @game.choose_color(letter, num, @cell)
        color = array[0]
        if color == 'none'
          answer = {form: '#form' }
        else
          other_tiles = array[1]
          answer = {legal: true, color: color, other_tiles: other_tiles, new_tiles: new_tiles}
        end
      else
        answer = {legal: false}
      end
    else
      answer = {legal: false}
    end
    byebug
    render :json => answer
  end

  private

  def game_params
    params.require(:game).permit(:bank, :up_next, :name, {:user_ids => []})
  end
end
