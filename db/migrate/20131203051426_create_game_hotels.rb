class CreateGameHotels < ActiveRecord::Migration
  def change
    create_table :game_hotels do |t|
      t.integer :share_price
      t.integer :chain_size
      t.string :tiles
      t.integer :game_id
      t.integer :hotel_id

      t.timestamps
    end
  end
end
