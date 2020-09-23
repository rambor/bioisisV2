class RenameColumnDatasetIdToDataSetId < ActiveRecord::Migration[6.0]
  def change
    rename_column :data_sets_materials, :dataset_id, :data_set_id
  end
end
