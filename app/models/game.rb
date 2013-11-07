class Game < ActiveRecord::Base
  has_many :game_players
  has_many :users, through: :game_players
end
