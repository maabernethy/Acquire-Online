class Game < ActiveRecord::Base
  has_many :log_entries
  has_many :game_players
  has_many :users, through: :game_players
  has_many :game_tiles
  has_many :tiles, through: :game_tiles
  has_many :game_stock_cards
  has_many :stock_cards, through: :game_stock_cards
  has_many :game_hotels
  has_many :hotels, through: :game_hotels
  
  GAME_BOARD = []
  game_row = []
  [1,2,3,4,5,6,7,8,9,10,11,12].each do |num|
    ['A','B','C','D','E','F', 'G','H','I'].each do |letter|
      cell_name = (num.to_s + letter)
      game_row.push(cell_name)
    end
    GAME_BOARD.push(game_row) 
    game_row = []
  end  

  #MOVE TO HOTEL MODEL WHEN CREATED
  HOTEL_COLORS = {
    "American" => "blue",
    "Continental" => "yellow",
    "Festival" => "red",
    "Imperial" => "green",
    "Sackson" => "orange",
    "Tower" => "purple",
    "Worldwide" => "pink",
    "none" => "grey"
  }   

  def get_hotel_color(hotel)
    HOTEL_COLORS[hotel]
  end
  
  def start_game
    self.deal_tiles
    self.make_stock_card_deck
    self.assign_order
    self.bank = 100000 - (self.game_players.length*6000)
    self.deal_cash
    self.initialize_hotels
    self.save
  end

  def assign_order
    num = 1
    self.game_players.each do |player|
      player.username = player.user.username
      player.turn_order = num
      if num == 1
        self.up_next = player.user.username
      end
      num = num + 1
      player.save
    end
  end

  def deal_cash
    self.game_players.each do |player|
      player.cash = 6000
      player.save
    end
  end

  def deal_tiles
    Tile.all.each do |tile|
      cell = tile.column.to_s + tile.row
      GameTile.create(tile_id: tile.id, game_id: self.id, hotel: 'none', cell: cell, placed: false, available: true)
    end
    self.game_players.each do |player|
      6.times do
        available_tiles = self.game_tiles.where(available: true)
        random_tile = available_tiles[rand(available_tiles.length)]
        random_tile.available = false
        random_tile.save
        GamePlayerTile.create(game_player_id: player.id, tile_id: random_tile.tile_id)
      end
    end
  end

  def make_stock_card_deck
    self.stock_cards = StockCard.all
  end

  def initialize_hotels
    Hotel.all.each do |hotel|
      GameHotel.create(name: hotel.name, hotel_id: hotel.id, game_id: self.id, chain_size: 0, share_price: 0)
    end
  end

  def is_current_players_turn?(current_player)
    if self.up_next == current_player
      true
    else
      false
    end
  end

  def player_hand(current_user, tile)
    player = current_user.game_players.where(game_id: self.id).first
    tiles = []
    player.tiles.each do |tile|
      tiles << (tile.column.to_s + tile.row)
    end

    if tiles.include? tile
      true
    else
      false
    end
  end

  def game_over?
    game_over = false
    safe_hotel_count = 0
    self.game_hotels.each do |hotel|
      if hotel.chain_size >= 41
        game_over = true
      elsif hotel.chain_size >= 11
        safe_hotel.count = safe_hotel.count + 1
      end
    end

    if safe_hotel_count = 7 || game_over = true
      end_game_scoring
    end
  end

  def end_game_scoring
    # for each founded hotel pay shareholders
    self.hotel_chains.each do |hotel|
      if hotel.chain_size > 0
        find_shareholders(hotel, hotel.chain_size)
      end
    end

    # for each player, sell stock at current share price
    self.game_players.each do |player|
      player.stock_cards.each do |stock|
        hotel = self.game_hotels.where(name: stock.hotel).first
        player.cash = player.cash + hotel.share_price
      end
    end
    player.save

    # determine winner
    most_money = 0
    self.game_players.each do |player|
      if player.cash > most_money
        winner = player
      end
    end

    #notify players of results
    msg2 = 'Player ' + winner.username + 'won ' + self.name 
    self.game_players.each do |player|
      if player = winner
        msg1 = 'You won ' + self.name
        Notification.create(message: msg1, user_id: player.user.id)
      else
        Notification.create(message: msg2, user_id: player.user.id)
      end
    end

    #delete game
    render :destroy
  end

  def end_turn
    current_username = self.up_next
    current_num = 0
    self.game_players.each do |player|
      if player.user.username == current_username
        current_num = player.turn_order
      end
    end
    if current_num == self.game_players.length
      next_num = 1
    else
      next_num = current_num + 1
    end
    next_player = self.game_players.where(turn_order: next_num).first
    self.up_next = next_player.user.username
    msg = current_username + ' has played their turn.'
    LogEntry.create(message: msg, game_id: self.id)
    notification = 'Its your move in ' + self.name
    Notification.create(message: notification, user_id: next_player.user.id)
    self.save
  end

  def start_merger_turn(current_player, acquired_hotel)
    byebug
    current_username = current_player.user.username
    current_num = 0
    self.game_players.each do |player|
      if player.user.username == current_username
        current_num = player.turn_order
      end
    end

    if current_num == self.game_players.length
      next_num = 1
    else
      next_num = current_num + 1
    end

    next_player = self.game_players.where(turn_order: next_num).first
    self.merger_up_next = next_player.user.username
    self.save
    byebug
    # if merger up next equals up_next then have gone full circle and call end merger turn
    if next_player.user.username == self.up_next
      if self.second_acquired_hotel != 'none'
        self.acquired_hotel = self.second_acquired_hotel
        self.second_acquired_hotel = 'none'
        m_turn = true
      else
        m_turn = false
      end
    else
      m_turn = true
    end

    players_w_shares = []
    self.game_players.each do |player|
      if player.stock_cards.where(hotel: self.acquired_hotel).count != 0
        players_w_shares << player
      end
    end

    # next player has no shares in acquired chain
    if players_w_shares.include?(next_player)
      self.has_shares = next_player.stock_cards.where(hotel: self.acquired_hotel).count 
    else
      self.has_shares = 0
    end

    self.save
    byebug
    [m_turn, self.has_shares]
  end

  def merger_stock(dominant_hotel, acquired_hotel, acquired_hotel_size)
    # get primary and secondary share holder of losing merger
    find_shareholders(acquired_hotel, acquired_hotel_size)
  end

  def find_shareholders(acquired_hotel, acquired_hotel_size)
    # determine share holders
    hotel_name = acquired_hotel.name
    most_shares = 0
    second_most_shares = 0
    majority_player = 'none'
    minority_player = 'none'
    tie_for_first = 'none'
    tie_for_second = 'none'
    self.game_players.each do |player|
      count = player.stock_cards.where(hotel: hotel_name).count
      if count > most_shares
        majority_player = player
        most_shares = count
        tie_for_first = 'none'
      elsif count = most_shares
        tie_for_first = player
      elsif count > second_most_shares
        minority_player = player
        second_most_shares = count
        tie_for_second = 'none'
      elsif count = second_most_shares
        tie_for_second = player
      end      
    end


    if minority_player == 'none' && tie_for_first == 'none'
      minority_player = majority_player
    end


    give_bonuses(acquired_hotel, majority_player, minority_player, acquired_hotel_size, tie_for_first, tie_for_second)
  end

  def give_bonuses(acquired_hotel, primary, secondary, acquired_hotel_size, tie_for_first, tie_for_second)
    response = acquired_hotel.get_bonus_amounts(acquired_hotel_size)
    majority_bonus = response[0]
    minority_bonus = response[1]

    if tie_for_first != 'none'
      split = (majority_bonus + minority_bonus)/2
      primary.cash = primary.cash + split
      tie_for_first.cash = tie_for_first.cash + split
      primary.save
      tie_for_first.save
      if tie_for_second != 'none'
        split = minority_bonus/2
        secondary.cash = secondary.cash + split
        tie_for_second.cash = tie_for_second.cash + split
        secondary.save
        tie_for_second.save
      end
    elsif tie_for_second != 'none'
      split = minority_bonus/2
      secondary.cash = secondary.cash + split
      tie_for_second.cash = tie_for_second.cash + split
      secondary.save
      tie_for_second.save
    else
      primary.cash = primary.cash + majority_bonus
      secondary.cash = secondary.cash + minority_bonus
      primary.save
      secondary.save
    end
  end

  def choose_color(row, column, cell, selected_hotel, player)
    tile = self.game_tiles.where(cell: cell).first
    placed_tiles = []
    self.game_tiles.where(placed: true).each do |game_tile|
      placed_tiles << game_tile.tile.column.to_s + game_tile.tile.row
    end
    sur_tiles = get_surrounding_tiles(row, column, cell)
    placed_sur_tiles = get_placed_surrounding_tiles(sur_tiles, placed_tiles)
    merger = false
    merger_three = false
    if placed_sur_tiles.length == 0
      color = "grey"
    elsif placed_sur_tiles.length == 1
      byebug
      if placed_sur_tiles[0].hotel == 'none'
        byebug
        if selected_hotel == 'none'
          # need input from user for new chain
          raise 'Ambiguous color'
        else
          # new chain
          other_tiles = convert_tile_to_number({'row' => placed_sur_tiles[0].tile.row, 'column' => placed_sur_tiles[0].tile.column})
          color = HOTEL_COLORS[selected_hotel]
          # Update Game log
          msg = player.username + ' founded ' + selected_hotel + '.'
          LogEntry.create(message: msg, game_id: self.id)
          #save game hotel chain size
          chosen_game_hotel = self.game_hotels.where(name: selected_hotel).first
          chosen_game_hotel.chain_size = 2
          chosen_game_hotel.save
          chosen_game_hotel.update_share_price
          #save other tile hotel
          placed_sur_tiles[0].hotel = selected_hotel
          placed_sur_tiles[0].save
          #save placed tile hotel
          tile.hotel = selected_hotel
          tile.save
        end
      else
        byebug
        # extending chain
        hotel = placed_sur_tiles[0].hotel
        color = HOTEL_COLORS[hotel]
        # Update Game log
        msg = player.username + ' extended ' + hotel + '.'
        LogEntry.create(message: msg, game_id: self.id)
        #save game hotel chain size
        hotel_chain = self.game_hotels.where(name: hotel).first
        hotel_chain.chain_size += 1
        hotel_chain.save
        hotel_chain.update_share_price
        #save placed tile hotel
        tile.hotel = hotel
        tile.save
      end
    elsif placed_sur_tiles.length == 2
      byebug
      if (placed_sur_tiles[0].hotel == 'none') && (placed_sur_tiles[1].hotel == 'none')
        byebug
        #new chain with chain size 3
        if selected_hotel == 'none'
          # need input from user for new chain
          raise 'Ambiguous color'
        else
          # new chain
          color = HOTEL_COLORS[selected_hotel]
          orphan_tiles_info = [[placed_sur_tiles[0].tile.row, placed_sur_tiles[0].tile.column, 'grey'], [placed_sur_tiles[1].tile.row, placed_sur_tiles[1].tile.column, 'grey']]
          other_tiles = convert_tiles_to_numbers(orphan_tiles_info)
          # Update Game log
          msg = player.username + ' founded ' + selected_hotel + '.'
          LogEntry.create(message: msg, game_id: self.id)
          #save game hotel chain size
          chosen_game_hotel = self.game_hotels.where(name: selected_hotel).first
          chosen_game_hotel.chain_size = 3
          chosen_game_hotel.save
          chosen_game_hotel.update_share_price
          #save other tiles hotels
          placed_sur_tiles[0].hotel = selected_hotel
          placed_sur_tiles[1].hotel = selected_hotel
          placed_sur_tiles[0].save
          placed_sur_tiles[1].save
          #save placed tile hotel
          tile.hotel = selected_hotel
          tile.save
        end
      elsif (placed_sur_tiles[0].hotel != 'none') && (placed_sur_tiles[1].hotel != 'none')
        if (placed_sur_tiles[0].hotel == placed_sur_tiles[1].hotel)
          byebug
          # extension of chain by 1
          hotel = placed_sur_tiles[0].hotel
          color = HOTEL_COLORS[hotel]
          hotel_chain = self.game_hotels.where(name: hotel).first
          hotel_chain.chain_size += 1
          hotel_chain.save
          hotel_chain.update_share_price
          tile.hotel = hotel
          tile.save
          # Update Game log
          msg = player.username + ' extended ' + hotel + '.'
          LogEntry.create(message: msg, game_id: self.id)
        else
          byebug
          #merger of 2 chains
          response = execute_merger(placed_sur_tiles, false, tile)
          other_tiles = convert_tiles_to_numbers(response[1])
          color = response[0]
          dominant_hotel = response[2]
          acquired_hotel = response[3]
          acquired_hotel_size = response[4]
          # Update Game log
          msg = player.username + ' caused a merger. ' + dominant_hotel.name + ' acquired ' + acquired_hotel.name + '.'
          LogEntry.create(message: msg, game_id: self.id)
          merger_stock(dominant_hotel, acquired_hotel, acquired_hotel_size)
          merger = true
        end
      elsif ((placed_sur_tiles[0].hotel == 'none') && (placed_sur_tiles[1].hotel != 'none')) || ((placed_sur_tiles[0].hotel != 'none') && (placed_sur_tiles[1].hotel == 'none'))
        byebug
        #extend chain with 2
        if placed_sur_tiles[0].hotel != 'none'
          hotel = placed_sur_tiles[0].hotel
          color = HOTEL_COLORS[hotel]
          hotel_chain = self.game_hotels.where(name: hotel).first
          hotel_chain.chain_size += 2
          hotel_chain.save
          hotel_chain.update_share_price
          placed_sur_tiles[1].hotel = hotel
          placed_sur_tiles[1].save
          other_tiles = convert_tile_to_number({'row' => placed_sur_tiles[1].tile.row, 'column' => placed_sur_tiles[1].tile.column, 'current_color' => 'grey'})
          tile.hotel = hotel
          tile.save
          # Update Game log
          msg = player.username + ' extended ' + hotel + '.'
          LogEntry.create(message: msg, game_id: self.id)
        elsif placed_sur_tiles[1].hotel != 'none'
          hotel = placed_sur_tiles[1].hotel
          color = HOTEL_COLORS[hotel]
          hotel_chain = self.game_hotels.where(name: hotel).first
          hotel_chain.chain_size += 2
          hotel_chain.save
          hotel_chain.update_share_price
          placed_sur_tiles[0].hotel = hotel
          placed_sur_tiles[0].save
          tile.hotel = hotel
          tile.save
          other_tiles = convert_tile_to_number({'row' => placed_sur_tiles[0].tile.row, 'column' => placed_sur_tiles[0].tile.column, 'current_color' => 'grey'})
          # Update Game log
          msg = player.username + ' extended ' + selected_hotel + '.'
          LogEntry.create(message: msg, game_id: self.id)
        end
      end
    elsif placed_sur_tiles.length == 3
      byebug
      # same options as with 2
      if (placed_sur_tiles[0].hotel == 'none') && (placed_sur_tiles[1].hotel == 'none') && (placed_sur_tiles[2].hotel == 'none')
        byebug
        #new chain with chain size 4
        if selected_hotel == 'none'
          # need input from user for new chain
          raise 'Ambiguous color'
        else
          # new chain
          color = HOTEL_COLORS[selected_hotel]
          orphan_tiles_info = [[placed_sur_tiles[0].tile.row, placed_sur_tiles[0].tile.column, 'grey'], [placed_sur_tiles[1].tile.row, placed_sur_tiles[1].tile.column, 'grey'], [placed_sur_tiles[2].tile.row, placed_sur_tiles[2].tile.column, 'grey']]
          other_tiles = convert_tiles_to_numbers(orphan_tiles_info)
          #save game hotel chain size
          chosen_game_hotel = self.game_hotels.where(name: selected_hotel).first
          chosen_game_hotel.chain_size = 4
          chosen_game_hotel.save
          chosen_game_hotel.update_share_price
          #save other tiles hotels
          placed_sur_tiles[0].hotel = selected_hotel
          placed_sur_tiles[1].hotel = selected_hotel
          placed_sur_tiles[2].hotel = selected_hotel
          placed_sur_tiles[0].save
          placed_sur_tiles[1].save
          placed_sur_tiles[2].save
          #save placed tile hotel
          tile.hotel = selected_hotel
          tile.save
          # Update Game log
          msg = player.username + ' founded ' + selected_hotel + '.'
          LogEntry.create(message: msg, game_id: self.id)
        end
      elsif (placed_sur_tiles[0].hotel != 'none') && (placed_sur_tiles[1].hotel != 'none') && (placed_sur_tiles[2].hotel != 'none')
        byebug
        if [placed_sur_tiles[0].hotel, placed_sur_tiles[1].hotel, placed_sur_tiles[2].hotel].uniq.length == 1
          byebug
          #extension of chain by 1
          hotel = placed_sur_tiles[0].hotel
          color = HOTEL_COLORS[hotel]
          tile.hotel = hotel
          tile.save
          hotel_chain = self.game_hotels.where(name: hotel).first
          hotel_chain.chain_size += 1
          hotel_chain.save
          hotel_chain.update_share_price
          msg = player.username + ' extended ' + hotel + '.'
          LogEntry.create(message: msg, game_id: self.id)
        elsif ([placed_sur_tiles[0].hotel, placed_sur_tiles[1].hotel].uniq.length == 1) || ([placed_sur_tiles[0].hotel, placed_sur_tiles[2].hotel].uniq.length == 1) || ([placed_sur_tiles[1].hotel, placed_sur_tiles[2].hotel].uniq.length == 1)
          byebug
          # merger of 2 chains
          if ([placed_sur_tiles[0].hotel, placed_sur_tiles[1].hotel].uniq.length == 1)
            merger_tiles = [placed_sur_tiles[0], placed_sur_tiles[2]]
          else
            merger_tiles = [placed_sur_tiles[0], placed_sur_tiles[1]]
          end 
          response = execute_merger(merger_tiles, false, tile)
          other_tiles = convert_tiles_to_numbers(response[1])
          color = response[0]
          dominant_hotel = response[2]
          acquired_hotel = response[3]
          acquired_hotel_size = response[4]
          # Update Game log
          msg = player.username + ' caused a merger. ' + dominant_hotel.name + ' acquired ' + acquired_hotel.name + '.'
          LogEntry.create(message: msg, game_id: self.id)
          merger_stock(dominant_hotel, acquired_hotel, acquired_hotel_size)
          merger = true
        else
          byebug 
          #merger of 3 chains
          response = big_merger(placed_sur_tiles, tile)
          other_tiles = convert_tiles_to_numbers(response[1])
          color = response[0]
          dominant_hotel = response[2]
          acquired_hotel1 = response[3]
          acquired_hotel1_size = response[4]
          acquired_hotel2 = response[5]
          acquired_hotel2_size = response[6]
          # Update Game log
          msg = player.username + ' caused a merger wit 3 chains. ' + dominant_hotel.name + ' acquired ' + acquired_hotel1.name + ' and ' + acquired_hotel1.name + '.'
          LogEntry.create(message: msg, game_id: self.id)
          merger_stock(dominant_hotel, acquired_hotel1, acquired_hotel1_size)
          merger_stock(dominant_hotel, acquired_hotel2, acquired_hotel2_size)
          merger_three = true
        end
      elsif ((placed_sur_tiles[0].hotel == 'none') && (placed_sur_tiles[1].hotel != 'none') && (placed_sur_tiles[2].hotel != 'none')) || ((placed_sur_tiles[0].hotel != 'none') && (placed_sur_tiles[1].hotel != 'none') && (placed_sur_tiles[2].hotel == 'none')) || ((placed_sur_tiles[0].hotel != 'none') && (placed_sur_tiles[1].hotel == 'none') && (placed_sur_tiles[2].hotel != 'none'))
        byebug
        # 1 orphan, 2 part of chains
        if ((placed_sur_tiles[0].hotel == placed_sur_tiles[1].hotel) || (placed_sur_tiles[0].hotel == placed_sur_tiles[2].hotel) || (placed_sur_tiles[2].hotel == placed_sur_tiles[1].hotel))
          # extension of chain by 2
          if placed_sur_tiles[0].hotel != 'none'
            hotel = placed_sur_tiles[0].hotel
            color = HOTEL_COLORS[hotel]
            if placed_sur_tiles[1].hotel != 'none'
              orphan_tile = placed_sur_tiles[2]
            else
              orphan_tile = placed_sur_tiles[1]
            end
            orphan_tile.hotel = hotel
            orphan_tile.save
            other_tiles = convert_tile_to_number({'row' => orphan_tile.tile.row, 'column' => orphan_tile.tile.column, 'current_color' => 'grey'})
            tile.hotel = hotel
            tile.save
            # Update Game log
            msg = player.username + ' extended ' + hotel + '.'
            LogEntry.create(message: msg, game_id: self.id)
          elsif placed_sur_tiles[1].hotel != 'none'
            hotel = placed_sur_tiles[0].hotel
            color = HOTEL_COLORS[hotel]
            if placed_sur_tiles[0].hotel != 'none'
              orphan_tile = placed_sur_tiles[2]
            else
              orphan_tile = placed_sur_tiles[0]
            end
            orphan_tile.hotel = hotel
            orphan_tile.save
            other_tiles = convert_tile_to_number({'row' => orphan_tile.tile.row, 'column' => orphan_tile.tile.column, 'current_color' => 'grey'})
            tile.hotel = hotel
            tile.save
            # Update Game log
            msg = player.username + ' extended ' + hotel + '.'
            LogEntry.create(message: msg, game_id: self.id)
          end
          hotel_chain = self.game_hotels.where(name: hotel).first
          hotel_chain.chain_size += 2
          hotel_chain.save
          hotel_chain.update_share_price
        else
          byebug
          # merger with 2 chains and 1 orphan
          response = merger_and_orphan(placed_sur_tiles, tile)
          other_tiles = convert_tiles_to_numbers(response[1])
          color = response[0]
          dominant_hotel = response[2]
          acquired_hotel = response[3]
          acquired_hotel_size = response[4]
          # Update Game log
          msg = player.username + ' caused a merger. ' + dominant_hotel.name + ' acquired ' + acquired_hotel.name + '.'
          LogEntry.create(message: msg, game_id: self.id)
          merger_stock(dominant_hotel, acquired_hotel, acquired_hotel_size)
          merger = true
        end
      elsif ((placed_sur_tiles[0].hotel == 'none') && (placed_sur_tiles[1].hotel == 'none') && (placed_sur_tiles[2].hotel != 'none')) || ((placed_sur_tiles[0].hotel == 'none') && (placed_sur_tiles[1].hotel != 'none') && (placed_sur_tiles[2].hotel == 'none')) || ((placed_sur_tiles[0].hotel != 'none') && (placed_sur_tiles[1].hotel == 'none') && (placed_sur_tiles[2].hotel == 'none'))
        byebug
        # extension of chain with 2 orphans
        if placed_sur_tiles[0].hotel != 'none'
          hotel = placed_sur_tiles[0].hotel
          color = HOTEL_COLORS[hotel]
          hotel_chain = self.game_hotels.where(name: hotel).first
          hotel_chain.chain_size += 3
          hotel_chain.save
          hotel_chain.update_share_price
          placed_sur_tiles[1].hotel = hotel
          placed_sur_tiles[1].save
          placed_sur_tiles[2].hotel = hotel
          placed_sur_tiles[2].save
          tile.hotel = hotel
          tile.save
          orphan_tiles_info = [[placed_sur_tiles[1].tile.row, placed_sur_tiles[1].tile.column, 'grey'], [placed_sur_tiles[2].tile.row, placed_sur_tiles[2].tile.column, 'grey']]
          other_tiles = convert_tiles_to_numbers(orphan_tiles_info)
        elsif placed_sur_tiles[1].hotel != 'none'
          hotel = placed_sur_tiles[1].hotel
          color = HOTEL_COLORS[hotel]
          hotel_chain = self.game_hotels.where(name: hotel).first
          hotel_chain.chain_size += 3
          hotel_chain.save
          hotel_chain.update_share_price
          placed_sur_tiles[0].hotel = hotel
          placed_sur_tiles[0].save
          placed_sur_tiles[2].hotel = hotel
          placed_sur_tiles[2].save
          tile.hotel = hotel
          tile.save
          orphan_tiles_info = [[placed_sur_tiles[0].tile.row, placed_sur_tiles[0].tile.column, 'grey'], [placed_sur_tiles[2].tile.row, placed_sur_tiles[2].tile.column, 'grey']]
          other_tiles = convert_tiles_to_numbers(orphan_tiles_info)
        elsif placed_sur_tiles[2].hotel != 'none'
          hotel = placed_sur_tiles[2].hotel
          color = HOTEL_COLORS[hotel]
          hotel_chain = self.game_hotels.where(name: hotel).first
          hotel_chain.chain_size += 3
          hotel_chain.save
          hotel_chain.update_share_price
          placed_sur_tiles[0].hotel = hotel
          placed_sur_tiles[0].save
          placed_sur_tiles[1].hotel = hotel
          placed_sur_tiles[1].save
          tile.hotel = hotel
          tile.save
          orphan_tiles_info = [[placed_sur_tiles[0].tile.row, placed_sur_tiles[0].tile.column, 'grey'], [placed_sur_tiles[1].tile.row, placed_sur_tiles[1].tile.column, 'grey']]
          other_tiles = convert_tiles_to_numbers(orphan_tiles_info)       
        end
        # Update Game log
        msg = player.username + ' extended ' + hotel + '.'
        LogEntry.create(message: msg, game_id: self.id)
      end
    elsif placed_sur_tiles.length == 4
      if (placed_sur_tiles[0].hotel == 'none') && (placed_sur_tiles[1].hotel == 'none') && (placed_sur_tiles[2].hotel == 'none') && (placed_sur_tiles[3].hotel == 'none')
        # 4 orphans, new chain of 5
        byebug
        if selected_hotel == 'none'
          # need input from user for new chain
          raise 'Ambiguous color'
        else
          # new chain
          color = HOTEL_COLORS[selected_hotel]
          orphan_tiles_info = [[placed_sur_tiles[0].tile.row, placed_sur_tiles[0].tile.column, 'grey'], [placed_sur_tiles[1].tile.row, placed_sur_tiles[1].tile.column, 'grey'], [placed_sur_tiles[2].tile.row, placed_sur_tiles[2].tile.column, 'grey'], [placed_sur_tiles[3].tile.row, placed_sur_tiles[3].tile.column, 'grey']]
          other_tiles = convert_tiles_to_numbers(orphan_tiles_info)
          #save game hotel chain size
          chosen_game_hotel = self.game_hotels.where(name: selected_hotel).first
          chosen_game_hotel.chain_size = 5
          chosen_game_hotel.save
          chosen_game_hotel.update_share_price
          #save other tiles hotels
          placed_sur_tiles[0].hotel = selected_hotel
          placed_sur_tiles[1].hotel = selected_hotel
          placed_sur_tiles[2].hotel = selected_hotel
          placed_sur_tiles[3].hotel = selected_hotel
          placed_sur_tiles[0].save
          placed_sur_tiles[1].save
          placed_sur_tiles[2].save
          placed_sur_tiles[3].save
          #save placed tile hotel
          tile.hotel = selected_hotel
          tile.save
          # Update Game log
          msg = player.username + ' founded ' + selected_hotel + '.'
          LogEntry.create(message: msg, game_id: self.id)
        end
      end
    else
      byebug
      return false    
    end
    byebug 
    if !merger && !merger_three
      byebug
      return [color, other_tiles, merger, merger_three]
    else
      if merger
        return [color, other_tiles, merger, merger_three, acquired_hotel.name]
      else
        return [color, other_tiles, merger, merger_three, acquired_hotel1.name, acquired_hotel2.name]
      end
    end
  end

  # convert to number so that can change color with javascript
  def convert_tile_to_number(cell)
    row = cell['row']
    column = cell['column']
    convert = {}
    nums = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I']
    letters.zip(nums) do |letter, num|
      convert[letter] = num
    end

    cell_number = ((convert[row] - 1)* 12) + (column - 1)
    response = cell_number

    if !cell['current_color'].nil?
      response = [cell_number, cell['current_color']]
    end

    response
  end

  def convert_tiles_to_numbers(cells)
    tiles_info = []
    cells.each do |cell|
      tiles_info << convert_tile_to_number({'row' => cell[0], 'column' => cell[1], 'current_color' => cell[2]})
    end

    tiles_info
  end

  def get_surrounding_tiles(row, column, cell)
    surrounding_tiles = []
    index = GAME_BOARD[column-1].index(cell)
    if column == 1 
      if index == 0
        surrounding_tiles << GAME_BOARD[column-1][index+1]
        surrounding_tiles << GAME_BOARD[column][index]
      elsif index == 8
        surrounding_tiles << GAME_BOARD[column-1][index-1]
        surrounding_tiles << GAME_BOARD[column][index]
      else
        surrounding_tiles << GAME_BOARD[column-1][index-1] 
        surrounding_tiles << GAME_BOARD[column-1][index+1] 
        surrounding_tiles << GAME_BOARD[column][index]
      end
    elsif column == 12
      if index == 0
        surrounding_tiles << GAME_BOARD[column-1][index+1]
        surrounding_tiles << GAME_BOARD[column-2][index] 
      elsif index == 8
        surrounding_tiles << GAME_BOARD[column-1][index-1]
        surrounding_tiles << GAME_BOARD[column-2][index] 
      else
        surrounding_tiles << GAME_BOARD[column-1][index-1] 
        surrounding_tiles << GAME_BOARD[column-1][index+1] 
        surrounding_tiles << GAME_BOARD[column-2][index]
      end
    elsif index == 0
      surrounding_tiles << GAME_BOARD[column-1][index+1] 
      surrounding_tiles << GAME_BOARD[column][index]
      surrounding_tiles << GAME_BOARD[column-2][index]
    elsif index == 8
      surrounding_tiles << GAME_BOARD[column-1][index-1] 
      surrounding_tiles << GAME_BOARD[column][index]
      surrounding_tiles << GAME_BOARD[column-2][index]
    else
      surrounding_tiles << GAME_BOARD[column-1][index+1] 
      surrounding_tiles << GAME_BOARD[column-1][index-1] 
      surrounding_tiles << GAME_BOARD[column][index]
      surrounding_tiles << GAME_BOARD[column-2][index]
    end

    surrounding_tiles
  end

  def get_placed_surrounding_tiles(sur_tiles, placed_tiles)
    placed_sur_tiles = []
    sur_tiles.each do |tile|
      if placed_tiles.include?(tile)
        tile_object = self.game_tiles.where(cell: tile).first
        placed_sur_tiles << tile_object
      end
    end

    placed_sur_tiles
  end

  def merger_and_orphan(placed_sur_tiles, placed_tile)
    if placed_sur_tiles[0].hotel == 'none'
      response = execute_merger([placed_sur_tiles[1], placed_sur_tiles[2]], true, placed_tile)
      other_tiles = response[1]
      other_tiles << [placed_sur_tiles[0].tile.row, placed_sur_tiles[0].tile.column, 'grey']
      color = response[0]
      placed_sur_tiles[0].hotel = Hotel.where(color: color).first.name
      dominant_hotel = response[2]
      acquired_hotel = response[3]
      acquired_hotel_size = response[4]
    elsif placed_sur_tiles[1].hotel == 'none'
      response = execute_merger([placed_sur_tiles[0], placed_sur_tiles[2]], true, placed_tile)
      other_tiles = response[1]
      other_tiles << [placed_sur_tiles[1].tile.row, placed_sur_tiles[1].tile.column, 'grey']
      color = response[0]
      placed_sur_tiles[1].hotel = Hotel.where(color: color).first.name
      dominant_hotel = response[2]
      acquired_hotel = response[3]
      acquired_hotel_size = response[4]
    elsif placed_sur_tiles[2].hotel == 'none'
      response = execute_merger([placed_sur_tiles[0], placed_sur_tiles[1]], true, placed_tile)
      other_tiles = response[1]
      other_tiles << [placed_sur_tiles[2].tile.row, placed_sur_tiles[2].tile.column, 'grey']
      color = response[0]
      placed_sur_tiles[2].hotel = Hotel.where(color: color).first.name
      dominant_hotel = response[2]
      acquired_hotel = response[3]
      acquired_hotel_size = response[4]
    end 

    [color, other_tiles, dominant_hotel, acquired_hotel, acquired_hotel_size]
  end

  def  big_merger(placed_sur_tiles, placed_tile)
    other_tiles = []
    hotel_name1 = placed_sur_tiles[0].hotel
    hotel_name2 = placed_sur_tiles[1].hotel
    hotel_name3 = placed_sur_tiles[2].hotel
    game_hotel1 = self.game_hotels.where(name: hotel_name1).first
    game_hotel2 = self.game_hotels.where(name: hotel_name2).first
    game_hotel3 = self.game_hotels.where(name: hotel_name3).first
    if (game_hotel1.chain_size >= game_hotel2.chain_size) && (game_hotel1.chain_size >= game_hotel3.chain_size)
      dominant_hotel = game_hotel1.hotel
      acquired_hotel1 = game_hotel2
      acquired_hotel2 = game_hotel3
      color = dominant_hotel.color
      c2 = game_hotel2.hotel.color
      c3 = game_hotel3.hotel.color
      game_tiles2 = self.game_tiles.where(hotel: hotel_name2)
      game_tiles2.each do |tile|
        tile.hotel = dominant_hotel.name
        tile.save
        temp = [tile.tile.row, tile.tile.column, c2]
        other_tiles << temp
      end
      game_tiles3 = self.game_tiles.where(hotel: hotel_name3)
      game_tiles3.each do |tile|
        tile.hotel = dominant_hotel.name
        tile.save
        temp = [tile.tile.row, tile.tile.column, c3]
        other_tiles << temp
      end
      game_hotel1.chain_size += game_tiles2.length + game_tiles3.length
      game_hotel1.save
      game_hotel1.update_share_price
      game_hotel2.chain_size = 0
      game_hotel2.save
      game_hotel2.update_share_price
      game_hotel3.chain_size = 0
      game_hotel3.save
      game_hotel3.update_share_price
    elsif (game_hotel2.chain_size >= game_hotel1.chain_size) && (game_hotel2.chain_size >= game_hotel3.chain_size)
      dominant_hotel = game_hotel2.hotel
      acquired_hotel1 = game_hotel1
      acquired_hotel2 = game_hotel3
      color = dominant_hotel.color
      c1 = game_hotel1.hotel.color
      c3 = game_hotel3.hotel.color
      game_tiles1 = self.game_tiles.where(hotel: hotel_name1)
      game_tiles1.each do |tile|
        tile.hotel = dominant_hotel.name
        tile.save
        temp = [tile.tile.row, tile.tile.column, c1]
        other_tiles << temp
      end
      game_tiles3 = self.game_tiles.where(hotel: hotel_name3)
      game_tiles3.each do |tile|
        tile.hotel = dominant_hotel.name
        tile.save
        temp = [tile.tile.row, tile.tile.column, c3]
        other_tiles << temp
      end
      game_hotel2.chain_size += game_tiles1.length + game_tiles3.length
      game_hotel2.save
      game_hotel2.update_share_price
      game_hotel1.chain_size = 0
      game_hotel1.save
      game_hotel1.update_share_price
      game_hotel3.chain_size = 0
      game_hotel3.save
      game_hotel3.update_share_price
    elsif (game_hotel3.chain_size >= game_hotel1.chain_size) && (game_hotel3.chain_size >= game_hotel2.chain_size)
      dominant_hotel = game_hotel3.hotel
      acquired_hotel1 = game_hotel1
      acquired_hotel2 = game_hotel2
      color = dominant_hotel.color
      c1 = game_hotel1.hotel.color
      c2 = game_hotel2.hotel.color
      game_tiles1 = self.game_tiles.where(hotel: hotel_name1)
      game_tiles1.each do |tile|
        tile.hotel = dominant_hotel.name
        tile.save
        temp = [tile.tile.row, tile.tile.column, c1]
        other_tiles << temp
      end
      game_tiles2 = self.game_tiles.where(hotel: hotel_name2)
      game_tiles2.each do |tile|
        tile.hotel = dominant_hotel.name
        tile.save
        temp = [tile.tile.row, tile.tile.column, c2]
        other_tiles << temp
      end
      game_hotel3.chain_size += game_tiles1.length + game_tiles2.length
      game_hotel3.save
      game_hotel3.update_share_price
      game_hotel1.chain_size = 0
      game_hotel1.save
      game_hotel1.update_share_price
      game_hotel2.chain_size = 0
      game_hotel2.save
      game_hotel2.update_share_price
    end 

    [color, other_tiles, acquired_hotel1, acquired_hotel1_size, acquired_hotel2, acquired_hotel2_size]  
  end

  def execute_merger(placed_sur_tiles, orphan, placed_tile)
    other_tiles = []
    if orphan
      num = 1
    else
      num = 0
    end
    hotel_name1 = placed_sur_tiles[0].hotel
    hotel_name2 = placed_sur_tiles[1].hotel
    game_hotel1 = self.game_hotels.where(name: hotel_name1).first
    game_hotel2 = self.game_hotels.where(name: hotel_name2).first
    if game_hotel1.chain_size > game_hotel2.chain_size || game_hotel1.chain_size == game_hotel2.chain_size
      dominant_hotel = game_hotel1.hotel
      acquired_hotel = game_hotel2
      self.acquired_hotel = game_hotel2.name
      self.dominant_hotel = game_hotel1.name
      self.save
      color = dominant_hotel.color
      c = game_hotel2.hotel.color
      game_tiles = self.game_tiles.where(hotel: hotel_name2)
      game_tiles.each do |tile|
        tile.hotel = dominant_hotel.name
        tile.save
        temp = [tile.tile.row, tile.tile.column, c]
        other_tiles << temp
      end
      placed_tile.hotel = dominant_hotel.name
      placed_tile.save
      acquired_hotel_size = game_hotel2.chain_size
      game_hotel1.chain_size += game_tiles.length + num + 1
      game_hotel1.save
      game_hotel1.update_share_price
      game_hotel2.chain_size = 0
      game_hotel2.save
      game_hotel2.update_share_price
    elsif game_hotel2.chain_size > game_hotel1.chain_size
      dominant_hotel = game_hotel2.hotel
      acquired_hotel = game_hotel1
      self.acquired_hotel = game_hotel1.name
      self.dominant_hotel = game_hotel2.name
      self.save
      color = dominant_hotel.color
      c = game_hotel1.hotel.color
      game_tiles = self.game_tiles.where(hotel: hotel_name1)
      game_tiles.each do |tile|
        tile.hotel = dominant_hotel.name
        tile.save
        temp = [tile.tile.row, tile.tile.column, c]
        other_tiles << temp
      end
      placed_tile.hotel = dominant_hotel.name
      placed_tile.save
      acquired_hotel_size = game_hotel1.chain_size
      game_hotel2.chain_size += game_tiles.length + num + 1
      game_hotel2.save
      game_hotel2.update_share_price
      game_hotel1.chain_size = 0
      game_hotel1.save
      game_hotel1.update_share_price
    end

    [color, other_tiles, dominant_hotel, acquired_hotel, acquired_hotel_size]
  end
end
