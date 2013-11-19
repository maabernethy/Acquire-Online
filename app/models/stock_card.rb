class StockCard < ActiveRecord::Base
  has_many :game_stock_cards
  has_many :games, through: :game_stock_cards
  has_many :game_player_stock_cards
  has_many :game_players, through: :game_player_stock_cards

end
