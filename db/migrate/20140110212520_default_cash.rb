class DefaultCash < ActiveRecord::Migration
  def change
    change_column_default :game_players, :cash, 0
  end
end
