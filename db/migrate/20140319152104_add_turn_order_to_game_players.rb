class AddTurnOrderToGamePlayers < ActiveRecord::Migration
  def change
    add_column :game_players, :turn_order, :integer
  end
end
