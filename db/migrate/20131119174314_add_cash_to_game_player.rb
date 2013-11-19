class AddCashToGamePlayer < ActiveRecord::Migration
  def change
    add_column :game_players, :cash, :integer
  end
end
