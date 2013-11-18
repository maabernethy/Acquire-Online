class CreateGameStockCards < ActiveRecord::Migration
  def change
    create_table :game_stock_cards do |t|
      t.integer :game_id
      t.integer :stock_card_id
      t.integer :price

      t.timestamps
    end
  end
end
