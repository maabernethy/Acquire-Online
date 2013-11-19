class AddRowToTile < ActiveRecord::Migration
  def change
    add_column :tiles, :row, :string
    add_column :tiles, :column, :integer
  end
end
