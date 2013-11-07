class GameTile < ActiveRecord::Base
  belongs_to :game
  belongs_to :tile
end
