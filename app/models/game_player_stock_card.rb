class GamePlayerStockCard < ActiveRecord::Base
  belongs_to :game_player
  belongs_to :stock_card
end
