class GamePlayer < ActiveRecord::Base
  belongs_to :user
  belongs_to :game
  has_many :game_player_tiles
  has_many :tiles, through: :game_player_tiles
  has_many :game_player_stock_cards
  has_many :stock_cards, through: :game_player_stock_cards

  def cash_to_english
    '$' + cash.to_s
  end
end
