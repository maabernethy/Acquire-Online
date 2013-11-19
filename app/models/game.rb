class Game < ActiveRecord::Base
  has_many :game_players
  has_many :users, through: :game_players
  has_many :game_tiles
  has_many :tiles, through: :game_tiles
  has_many :game_stock_cards
  has_many :stock_cards, through: :game_stock_cards

  def deal_tiles
    self.tiles = Tile.all
    self.game_players.each do |player|
      6.times do
        random_tile = self.tiles[rand(tiles.length)]
        GamePlayerTile.create(game_player_id: player.id, tile_id: random_tile.id)
      end
    end
  end
end
