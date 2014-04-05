class AddMergerToGame < ActiveRecord::Migration
  def change
    add_column :games, :merger, :integer
    add_column :games, :merger_up_next, :string
  end
end
