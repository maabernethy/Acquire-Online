class CreateGameTiles < ActiveRecord::Migration
  def change
    create_table :game_tiles do |t|
      t.integer :game_id
      t.integer :tile_id
      t.string :hotel

      t.timestamps
    end
  end
end
