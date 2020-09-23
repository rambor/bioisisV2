class ChangeReciprocalSpaceDatumToReciprocalSpaceFile < ActiveRecord::Migration[6.0]
  def change
    rename_table :reciprocal_space_data, :reciprocal_space_files
  end
end
