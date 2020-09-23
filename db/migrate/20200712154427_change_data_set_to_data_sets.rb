class ChangeDataSetToDataSets < ActiveRecord::Migration[6.0]
  def change
    rename_table :data_set, :data_sets
  end
end
