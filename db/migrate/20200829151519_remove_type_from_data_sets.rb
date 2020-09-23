class RemoveTypeFromDataSets < ActiveRecord::Migration[6.0]
  def change
    remove_column :data_sets, :sas_type
  end
end
