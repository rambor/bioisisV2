class ChangeColumnInRealSpaceData < ActiveRecord::Migration[6.0]
  def change
    rename_column :real_space_data, :data_set_id, :reciprocal_space_datum_id
  end
end
