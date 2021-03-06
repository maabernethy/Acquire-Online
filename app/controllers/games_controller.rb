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

  def destroy
    @game = Game.find(params[:id])
    if params[:user_deleted]
      @game.game_players.each do |player|
        unless player.user == current_user
          msg = current_user.username + ' deleted ' + @game.name
          Notification.create(message: msg, user_id: player.user.id)
        end
      end
    end
    @game.destroy
    redirect_to game_center_path
  end

  def show
    game_state
  end

  # called when user clicks of board game square
  # determines if tile placement is legal and passes updated data to front end
  def place_piece
    @game = Game.find(params[:id])
    player = current_user.game_players.where(game_id: @game.id).first
    if !params[:hotel].nil?
      selected_hotel = params[:hotel]
      hotel_stock_cards = @game.stock_cards.where(hotel: selected_hotel)
      if hotel_stock_cards.count > 0
        chosen_card = hotel_stock_cards.first
        @game.stock_cards.delete(chosen_card)
        @game.save
        player.stock_cards << chosen_card
        player.save
      end
    else
      selected_hotel = 'none'
    end
    @cell = params[:cell]
    num, letter = params[:num].to_i, params[:letter]
    @game_tile = @game.game_tiles.where(cell: @cell)
    if @game.merger != true && player.buy_stocks != true
      if @game.is_current_players_turn?(current_user)
        if @game.player_hand(current_user, @cell) 
          # throws exception if tile is part of new chain because need input from user
          begin
            array = @game.choose_color(letter, num, @cell, selected_hotel, player)
          rescue
            render :json => @game, :status => :unprocessable_entity
            return
          end

          if array == false
            answer = {legal: false}
          else
            # updates hand of tiles of player
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
            merger = array[2]
            merger_three = array[3]
            if merger
              @game.acquired_hotel = array[4]
              num_shares = player.stock_cards.where(hotel: @game.acquired_hotel).count
              @game.has_shares = num_shares
              @game.merger_up_next = player.username
            else
              if merger_three
                merger = true
                @game.acquired_hotel = array[4]
                num_shares = player.stock_cards.where(hotel: @game.acquired_hotel).count
                @game.has_shares = num_shares
                @game.second_acquired_hotel = array[5]
                @game.merger_up_next = player.username
              else
                @game.acquired_hotel = 'none'
              end
            end
            founded_hotels = @game.game_hotels.where('chain_size > 0')
            if founded_hotels.length == 0 
              @game.end_turn
            else
              player.buy_stocks = true
            end

            @game.save
            player.save
            answer = {legal: true, color: color, other_tiles: other_tiles, new_tiles: player.tiles, merger: merger, has_shares: @game.has_shares, acquired_hotel: @game.acquired_hotel}
          end      
        else
          answer = {legal: false}
        end
      else
        answer = {legal: false}
      end
    else
      answer = {legal: false}
    end
    # gets updated state of game and parses data as json and passes to front end
    game_state
    @payload[:answer] = answer
    render :json => @payload
  end

  # called when player has selected which hotel chains they want to purchase stock in
  # deals with selection accordingly by determining current share price and subtracting that from player's cash supply
  def buy_stocks
    hotel1 = params[:hotel1]
    hotel2 = params[:hotel2]
    hotel3 = params[:hotel3]
    @game = Game.find(params[:id])
    player = current_user.game_players.where(game_id: @game.id).first
    if hotel1 != 'none'
      game_hotel1 = @game.game_hotels.where(name: hotel1).first
      price1 = game_hotel1.share_price
      if player.cash >= price1
        card1 = @game.stock_cards.where(hotel: hotel1).first
        @game.stock_cards.delete(card1)
        @game.save
        player.stock_cards << card1
        player.cash = player.cash - price1
        player.save
      end
    end
    if hotel2 != 'none'
      game_hotel2 = @game.game_hotels.where(name: hotel2).first
      price2 = game_hotel2.share_price
      if player.cash >= price2
        card2 = @game.stock_cards.where(hotel: hotel2).first
        @game.stock_cards.delete(card2)
        @game.save
        player.stock_cards << card2
        player.cash = player.cash - price2
        player.save
      end
    end
    if hotel3 != 'none'
      game_hotel3 = @game.game_hotels.where(name: hotel3).first
      price3 = game_hotel3.share_price
      if player.cash >= price3
        card3 = @game.stock_cards.where(hotel: hotel3).first
        @game.stock_cards.delete(card3)
        @game.save
        player.stock_cards << card3
        player.cash = player.cash - price3
        player.save
      end
    end
    player.buy_stocks = false
    player.save
    game_over = @game.game_over?
    if game_over != false
      @game.destroy
      render :json => {game_over: true, winner: game_over}
    else
      @game.end_turn
      game_state
      render :json => @payload
    end
  end

  # called when a player's tile placement has caused a merger and they have selected what to do with their shares in the acquired hotel
  def merger_turn
    shares = params[:shares]
    hnum = params[:hold]
    tnum = params[:trade]
    snum = params[:sell]
    acquired_hotel = params[:acquired_hotel]
    game = Game.find(params[:id])
    game.acquired_hotel = acquired_hotel
    game.save
    player = current_user.game_players.where(game_id: game.id).first
    if shares
      hold_sell_trade(hnum, snum, tnum, player, game, acquired_hotel)
    end
    response = game.start_merger_turn(player, acquired_hotel)

    if response[0] == true
      game.merger = 2
      game.save
    elsif response[0] == false
      game.merger = 0
      game.merger_up_next = 'none'
      game.end_turn
      game.save
    end

    game_state

    if response[0] == false
      @payload[:merger] = false
    end

    game_over = game.game_over?
    if game_over != false
      game.destroy
      render :json => {game_over: true, winner: game_over}
    else
      render :json => @payload
    end
  end

  # deels with player's choice to hold, sell or trade their shares in acquired chain in event of merger
  def hold_sell_trade(hnum, snum, tnum, player, game, acquired_hotel)
    snum = snum.to_i
    tnum = tnum.to_i
    # do nothing when holding shares
    # deal with selling of shares
    if (snum > 0)
      # give player money
      acquired_game_hotel = game.game_hotels.where(name: acquired_hotel).first
      acquired_hotel_share_price = acquired_game_hotel.share_price
      player.cash = player.cash + (acquired_hotel_share_price * snum)
      # remove shares from stock cards and return to game pool
      snum.times do
        card = player.stock_cards.where(hotel: acquired_hotel).first
        player.stock_cards.delete(card)
        game.stock_cards << card
      end

      player.save
      game.save
    end

    # deal with trading of shares
    if (tnum > 0)
      dominant_hotel = game.dominant_hotel
      num_of_trades = tnum/2
      num_of_trades.times do
        2.times do
          a_card = player.stock_cards.where(hotel: acquired_hotel).first
          player.stock_cards.delete(a_card)
          game.stock_cards << a_card
        end
        d_card = game.stock_cards.where(hotel: dominant_hotel).first
        game.stock_cards.delete(d_card)
        player.stock_cards << d_card
      end

      player.save
      game.save
    end
  end

  private

  # polls database for current state of game and saves information in hash object
  def game_state
    game = Game.find(params[:id])
    log_entries = game.log_entries
    player = current_user.game_players.where(game: game).first
    tiles = player.tiles
    stocks = player.stock_cards_by_name_payload
    game_hotels = game.game_hotels
    founded_hotels = game_hotels.where('chain_size > 0')
    hotels_w_enough_stock_cards = []
    if founded_hotels.length != 0
      founded_hotels.each do |hotel|
        if game.stock_cards.where(hotel: hotel.name).count > 0
          hotels_w_enough_stock_cards << hotel
        end
      end
    end
    available_hotels = game_hotels.where(chain_size: 0)
    board_colors = get_board_colors(game)

    @payload = { game: game, players: game.game_players, tiles: tiles, player: player, stocks: stocks, game_hotels: game_hotels, available_hotels: available_hotels, board_colors: board_colors, founded_hotels: founded_hotels, hotels_w_enough_stock_cards: hotels_w_enough_stock_cards, log_entries: log_entries }
  end

  # determines what color each tile on board should be by looking at what hotel chain they are part of
  def get_board_colors(game)
    board_colors = {}
    [1,2,3,4,5,6,7,8,9,10,11,12].each do |num|
      ['A','B','C','D','E','F', 'G','H','I'].each do |letter|
        cell = (num.to_s + letter)
        board_colors[cell] = 'none'
      end
    end 
     
    placed_tiles = game.game_tiles.where(placed: true)
    placed_tiles.each do |game_tile|
      hotel = game_tile.hotel
      color = game.get_hotel_color(hotel)
      board_colors[game_tile.cell] = color
    end

    board_colors
  end

  def game_params
    params.require(:game).permit(:bank, :up_next, :name, {:user_ids => []})
  end
end
