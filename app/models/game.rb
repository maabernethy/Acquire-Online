class Game < ActiveRecord::Base
  has_many :game_players
  has_many :users, through: :game_players
  has_many :game_tiles
  has_many :tiles, through: :game_tiles
  has_many :game_stock_cards
  has_many :stock_cards, through: :game_stock_cards


  def hello
    true
  end
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
    self.tiles = Tile.all
    self.game_players.each do |player|
      6.times do
        random_tile = self.tiles[rand(tiles.length)]
        GamePlayerTile.create(game_player_id: player.id, tile_id: random_tile.id)
      end
    end
  end

  def make_stock_card_deck
    self.stock_cards = StockCard.all
  end
end
