class GamePlayerTile < ActiveRecord::Base
  belongs_to :game_player
  belongs_to :tile
end
