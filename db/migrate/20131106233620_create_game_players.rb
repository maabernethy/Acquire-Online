class CreateGamePlayers < ActiveRecord::Migration
  def change
    create_table :game_players do |t|
      t.integer :game_id
      t.integer :user_id

      t.timestamps
    end

    add_index :game_players, :game_id
    add_index :game_players, :user_id
  end
end
