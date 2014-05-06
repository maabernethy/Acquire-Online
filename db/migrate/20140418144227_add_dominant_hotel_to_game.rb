class AddDominantHotelToGame < ActiveRecord::Migration
  def change
    add_column :games, :dominant_hotel, :string
  end
end
