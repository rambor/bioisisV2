class ChangeColumnNameInDataFile < ActiveRecord::Migration[6.0]
  def change
    rename_column :data_files, :type, :sas_type
  end
end
