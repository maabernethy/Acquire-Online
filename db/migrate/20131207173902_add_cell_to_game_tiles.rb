class AddCellToGameTiles < ActiveRecord::Migration
  def change
    add_column :game_tiles, :cell, :string
  end
end
