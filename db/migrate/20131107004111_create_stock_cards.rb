class CreateStockCards < ActiveRecord::Migration
  def change
    create_table :stock_cards do |t|
      t.string :hotel
      t.integer :price

      t.timestamps
    end
  end
end
