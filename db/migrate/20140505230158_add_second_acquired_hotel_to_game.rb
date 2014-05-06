class AddSecondAcquiredHotelToGame < ActiveRecord::Migration
  def change
    add_column :games, :second_acquired_hotel, :string
    add_column :games, :second_num_shares, :integer
  end
end
