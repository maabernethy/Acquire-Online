class AddNameToGameHotel < ActiveRecord::Migration
  def change
    add_column :game_hotels, :name, :string
  end
end
