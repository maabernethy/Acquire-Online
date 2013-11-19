class Tile < ActiveRecord::Base
  has_many :game_tiles
  has_many :games, through: :game_tiles
  has_many :game_player_tiles
  has_many :game_players, through: :game_player_tiles

  TILES = [
    '1A','2A','3A','4A','5A','6A','7A','9A','10A','11A','12A',
    '1B','2B','3B','4B','5B','6B','7B','9B','10B','11B','12B',
    '1C','2C','3C','4C','5C','6C','7C','9C','10C','11C','12C',
    '1D','2D','3D','4D','5D','6D','7D','9D','10D','11D','12D',
    '1E','2E','3E','4E','5E','6E','7E','9E','10E','11E','12E',
    '1F','2F','3F','4F','5F','6F','7F','9F','10F','11F','12F',
    '1G','2G','3G','4G','5G','6G','7G','9G','10G','11G','12G',
    '1H','2H','3H','4H','5H','6H','7H','9H','10H','11H','12H',
    '1I','2I','3I','4I','5I','6I','7I','9I','10I','11I','12I',
  ]

  def tiles
    TILES
  end







end
