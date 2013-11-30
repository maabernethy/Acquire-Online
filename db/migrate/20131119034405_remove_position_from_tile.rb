class RemovePositionFromTile < ActiveRecord::Migration
  def change
    remove_column :tiles, :position
  end
end
