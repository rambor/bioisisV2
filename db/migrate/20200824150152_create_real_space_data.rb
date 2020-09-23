class CreateRealSpaceData < ActiveRecord::Migration[6.0]
  def change
    create_table :real_space_data do |t|
      t.decimal :rg
      t.decimal :dmax, :precision => 7, :scale => 2
      t.string :method, :null => true
      t.integer :data_set_id, :default => false
      t.timestamps
    end
  end
end
