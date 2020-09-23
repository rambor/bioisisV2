class CreateReciprocalSpaceData < ActiveRecord::Migration[6.0]
  def change
    create_table :reciprocal_space_data do |t|
      t.string :sas_type, default: "subtracted"
      t.integer :data_set_id, :null => false
      t.timestamps
    end
  end
end
