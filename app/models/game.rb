class Game < ActiveRecord::Base
  has_many :game_players
  has_many :users, through: :game_players
  has_many :game_tiles
  has_many :tiles, through: :game_tiles
  has_many :game_stock_cards
  has_many :stock_cards, through: :game_stock_cards


  def start_game
    self.deal_tiles
    self.make_stock_card_deck
    up_first = self.users.first.username
    self.up_next = up_first
    self.bank = 100000 - (self.game_players.length*6000)
    self.deal_cash
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
      GameTile.create(tile_id: tile.id, game_id: self.id, hotel: 'none', placed: false, available: true)
    end
    self.game_players.each do |player|
      6.times do
        available_tiles = self.game_tiles.where(available: true)
        random_tile = available_tiles[rand(available_tiles.length)]
        random_tile.available = false
        random_tile.save
        # self.game_tiles.where(tile_id: random_tile.id).first.available = false
        GamePlayerTile.create(game_player_id: player.id, tile_id: random_tile.tile_id)
      end
    end
  end

  def make_stock_card_deck
    self.stock_cards = StockCard.all
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

  def is_orphan?

  end

  def is_new_chain?

  end

  def is_chain_addition?

  end

  def is_merger?

  end
end
