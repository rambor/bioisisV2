class RenameTable < ActiveRecord::Migration[6.0]
  def change
    rename_table :datasets_materials, :data_sets_materials
  end
end
