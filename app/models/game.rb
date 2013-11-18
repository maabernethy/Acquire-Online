class Game < ActiveRecord::Base
  has_many :game_players
  has_many :users, through: :game_players
  has_many :game_tiles
  has_many :tiles, through: :game_tiles
  has_many :game_stock_cards
  has_many :stock_cards, through: :game_stock_cards
end
