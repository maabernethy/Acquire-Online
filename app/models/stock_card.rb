class StockCard < ActiveRecord::Base
  has_many :game_stock_cards
  has_many :games, through: :game_stock_cards
  has_many :game_player_stock_cards
  has_many :game_players, through: :game_player_stock_cards

  AMERICAN_STOCKS = []
  CARDS = [
    'A1','A2','A3','A4','A5','A6','A7','A8','A9','A10','A11','A12','A13','A14','A15','A16','A17',
    'C1',
    'F1',
    'I1',
    'L1',
    'T1',
    'W1'
  ]
end
