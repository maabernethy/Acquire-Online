class AddBankToGame < ActiveRecord::Migration
  def change
    add_column :games, :bank, :integer
  end
end
