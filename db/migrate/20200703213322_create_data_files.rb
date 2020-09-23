class CreateDataFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :data_files do |t|
      t.boolean :raw, :default => false
      t.string :name, :null => false
      t.string :type, :default => "subtracted"
      t.integer :experiment_id, :default => false
      t.timestamps
    end
  end
end
