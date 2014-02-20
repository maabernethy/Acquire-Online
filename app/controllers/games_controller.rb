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
    game_state
  end

  def place_piece
    if !params[:hotel].nil?
      selected_hotel = params[:hotel]
    else
      selected_hotel = 'none'
    end
    @cell = params[:cell]
    num, letter = params[:num].to_i, params[:letter]
    @game = Game.find(params[:id])
    @game_tile = @game.game_tiles.where(cell: @cell)
    player = current_user.game_players.where(game_id: @game.id).first
    # if @game.is_current_players_turn?(current_user)
    if true
      if @game.player_hand(current_user, @cell) 
        begin
          array = @game.choose_color(letter, num, @cell, selected_hotel)
        rescue
          render :json => @game, :status => :unprocessable_entity
          return
        end

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

        color = array[0]
        other_tiles = array[1]
        answer = {legal: true, color: color, other_tiles: other_tiles, new_tiles: player.tiles}
      else
        answer = {legal: false}
      end
    else
      answer = {legal: false}
    end
    game_state
    @payload[:answer] = answer
    render :json => @payload
  end

  private

  def game_state
    game = Game.find(params[:id])
    player = current_user.game_players.where(game: game).first
    tiles = player.tiles
    stocks = player.stock_cards_by_name_payload
    game_hotels = game.game_hotels
    available_hotels = game_hotels.where(chain_size: 0)
    board_colors = get_board_colors(game)

    @payload = { game: game, users: game.users, tiles: tiles, player: player, stocks: stocks, game_hotels: game_hotels, available_hotels: available_hotels, board_colors: board_colors }
  end

  def get_board_colors(game)
    board_colors = Hash.new{|hash, key| hash[key] = Array.new}
    ['A','B','C','D','E','F', 'G','H','I'].each do |letter|
        board_colors[letter] = Array.new(12)
        [0,1,2,3,4,5,6,7,8,9,10,11].each do |num|
          board_colors[letter][num] = 'none'
        end
    end
     
    placed_tiles = game.game_tiles.where(placed: true)
    placed_tiles.each do |game_tile|
      hotel = game_tile.hotel
      color = game.get_hotel_color(hotel)
      board_colors[game_tile.tile.row][game_tile.tile.column] = color
    end

    board_colors['A'][1] = 'blue'
    board_colors
    colors = { '1A' => 'blue', '3B' => 'pink'}
    colors
  end

  def game_params
    params.require(:game).permit(:bank, :up_next, :name, {:user_ids => []})
  end
end
