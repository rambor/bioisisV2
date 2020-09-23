class AddJsonFlagToReciprocalAndRealSpaceFiles < ActiveRecord::Migration[6.0]
  def change
    add_column :real_space_files, :json, :text
    add_column :reciprocal_space_files, :json, :text
  end
end
