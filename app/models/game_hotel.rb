class GameHotel < ActiveRecord::Base
	belongs_to :game
	belongs_to :hotel
end
