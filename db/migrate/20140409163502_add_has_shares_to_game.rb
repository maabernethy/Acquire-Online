class AddHasSharesToGame < ActiveRecord::Migration
  def change
    add_column :games, :has_shares, :integer
    add_column :games, :acquired_hotel, :string
  end
end
