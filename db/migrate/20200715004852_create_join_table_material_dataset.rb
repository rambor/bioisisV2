class CreateJoinTableMaterialDataset < ActiveRecord::Migration[6.0]
  def change
    create_join_table :materials, :datasets do |t|
      t.index [:material_id, :dataset_id]
      # t.index [:dataset_id, :material_id]
    end
  end
end
