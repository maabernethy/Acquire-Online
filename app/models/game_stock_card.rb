class GameStockCard < ActiveRecord::Base
  belongs_to :game
  belongs_to :stock_card
end
