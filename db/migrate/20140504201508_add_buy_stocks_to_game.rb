class AddBuyStocksToGame < ActiveRecord::Migration
  def change
    add_column :games, :buy_stocks, :boolean
  end
end
