class CreateGamePlayerTiles < ActiveRecord::Migration
  def change
    create_table :game_player_tiles do |t|
      t.integer :game_player_id
      t.integer :tile_id

      t.timestamps
    end
  end
end
