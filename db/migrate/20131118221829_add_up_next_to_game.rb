class AddUpNextToGame < ActiveRecord::Migration
  def change
    add_column :games, :up_next, :string
  end
end
