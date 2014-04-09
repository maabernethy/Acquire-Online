class AddAvailableToGameTile < ActiveRecord::Migration
  def change
    add_column :game_tiles, :available, :boolean
    add_column :game_tiles, :placed, :boolean
  end
end
