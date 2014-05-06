class AddBuyStocksToGamePlayer < ActiveRecord::Migration
  def change
    add_column :game_players, :buy_stocks, :boolean
  end
end
