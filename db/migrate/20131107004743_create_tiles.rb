class CreateTiles < ActiveRecord::Migration
  def change
    create_table :tiles do |t|
      t.string :position

      t.timestamps
    end
  end
end
