class ChangeColumnInRealSpaceFiles < ActiveRecord::Migration[6.0]
  def change
    rename_column :real_space_files, :reciprocal_space_datum_id, :reciprocal_space_file_id
  end
end
