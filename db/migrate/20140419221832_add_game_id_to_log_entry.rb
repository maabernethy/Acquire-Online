class AddGameIdToLogEntry < ActiveRecord::Migration
  def change
    add_column :log_entries, :game_id, :integer
  end
end
