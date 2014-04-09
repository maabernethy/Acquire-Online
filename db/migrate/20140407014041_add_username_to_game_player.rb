class AddUsernameToGamePlayer < ActiveRecord::Migration
  def change
    add_column :game_players, :username, :string
  end
end
