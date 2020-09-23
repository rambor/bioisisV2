class ChangeRealSpaceDatumToRealSpaceFile < ActiveRecord::Migration[6.0]
  def change
    rename_table :real_space_data, :real_space_files
  end
end
