class Hotel < ActiveRecord::Base
	has_many :game_hotels
	has_many :games, through: :game_hotels
end
