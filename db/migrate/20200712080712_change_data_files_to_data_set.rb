class ChangeDataFilesToDataSet < ActiveRecord::Migration[6.0]
  def change
    rename_table :data_files, :data_set
  end
end
