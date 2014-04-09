class Tile < ActiveRecord::Base
  has_many :game_tiles
  has_many :games, through: :game_tiles
  has_many :game_player_tiles
  has_many :game_players, through: :game_player_tiles

  def to_english
    column.to_s + row
  end

  def as_json(*)
    super(methods: :to_english)
  end
end
