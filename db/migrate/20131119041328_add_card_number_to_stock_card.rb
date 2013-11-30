class AddCardNumberToStockCard < ActiveRecord::Migration
  def change
    add_column :stock_cards, :card_number, :integer
  end
end
