class CreateGamePlayerStockCards < ActiveRecord::Migration
  def change
    create_table :game_player_stock_cards do |t|
      t.integer :game_player_id
      t.integer :stock_card_id

      t.timestamps
    end
  end
end
