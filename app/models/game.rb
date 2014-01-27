class Game < ActiveRecord::Base
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
    "Tower" => "black",
    "Worldwide" => "purple"
  }   
  
  def start_game
    self.deal_tiles
    self.make_stock_card_deck
    up_first = self.users.first.username
    self.up_next = up_first
    self.bank = 100000 - (self.game_players.length*6000)
    self.deal_cash
    self.initialize_hotels
    self.save
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

  def choose_color(row, column, cell, selected_hotel)
    placed_tiles = []
    self.game_tiles.where(placed: true).each do |game_tile|
      placed_tiles << game_tile.tile.column.to_s + game_tile.tile.row
    end
    sur_tiles = get_surrounding_tiles(row, column, cell)
    placed_sur_tiles = get_placed_surrounding_tiles(sur_tiles, placed_tiles)
    if placed_sur_tiles.length == 0
      color = "grey"
    elsif placed_sur_tiles.length == 1
      if placed_sur_tiles[0].hotel == 'none'
        byebug
        if selected_hotel == 'none'
          byebug
          # need input from user for new chain
          raise 'Ambiguous color'
        else
          # new chain
          byebug
          other_tiles = convert_tiles_to_number({'row' => placed_sur_tiles[0].tile.row, 'column' => placed_sur_tiles[0].tile.column})
          color = HOTEL_COLORS[selected_hotel]
          # chosen_game_hotel = game.game_hotels.where(name: selected_hotel)
          # chosen_game_hotel.chain_size = 2
          # chosen_game_hotel.save
        end
      else
        # extending chain
        hotel = placed_sur_tiles[0].hotel
        color = HOTEL_COLORS[hotel]
      end
    elsif placed_sur_tiles.length == 2
      # merger
      response = self.merger(placed_sur_tiles)
      color = response[0]
      other_tiles = response[1]
    end

    byebug
    [color, other_tiles]
  end

  # convert to number so that can change color with javascript
  def convert_tiles_to_number(cell)
    byebug
    row = cell['row']
    column = cell['column']
    convert = {}
    nums = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    letters = ['A', 'B', 'C', 'D', 'E', 'F', 'H', 'I']
    letters.zip(nums) do |letter, num|
      convert[letter] = num
    end
    cell_number = ((column - 1)* 9) + (convert[row]) - 1
  end

  def get_surrounding_tiles(row, column, cell)
    surrounding_tiles = []
    index = GAME_BOARD[column-1].index(cell)
    surrounding_tiles << GAME_BOARD[column-1][index-1] if !GAME_BOARD[column-1].nil? && !GAME_BOARD[column-1][index-1].nil?
    surrounding_tiles << GAME_BOARD[column-1][index+1] if !GAME_BOARD[column-1].nil? && !GAME_BOARD[column-1][index+1].nil?
    surrounding_tiles << GAME_BOARD[column-2][index] if !GAME_BOARD[column-2].nil? && !GAME_BOARD[column-1][index].nil?
    surrounding_tiles << GAME_BOARD[column][index] if !GAME_BOARD[column].nil? && !GAME_BOARD[column][index].nil?

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

  def merger
    hotel_name1 = placed_sur_tiles[0].hotel
    hotel_name2 = placed_sur_tiles[1].hotel
    id1 = Hotel.where(name: hotel_name1)
    id2 = Hotel.where(name: hotel_name2)
    game_hotel1 = self.game_hotels.where(hotel_id: id1)
    game_hotel2 = self.game_hotels.where(hotel_id: id2)
    if game_hotel1.chain_size > game_hotel2.chain_size
      color = game_hotel1.hotel.color
    elsif game_hotel2.chain_size > game_hotel1.chain_size
      color = game_hotel2.hotel.color
    end

    tiles1 = self.game_tiles.where(hotel: hotel_name1)
    tiles2 = self.game_tiles.where(hotel: hotel_name2)
    tiles = tiles1 + tiles2
    other_tiles = []
    tiles.each do |tile|
      other_tiles << tile.cell
    end

    [color, other_tiles]
  end

  def new_chain_color(cell, other_tile)
    tile = self.game_tiles.where(cell: cell)
    hotel = tile.hotel
    other_tile.hotel = hotel
    game_hotel = self.game_hotels.where(name: hotel)
    game_hotel.chain_size = 2
    color = HOTEL_COLORS.hotel
  end
end
