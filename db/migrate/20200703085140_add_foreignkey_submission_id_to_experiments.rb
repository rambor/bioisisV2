class AddForeignkeySubmissionIdToExperiments < ActiveRecord::Migration[6.0]
  def change
    add_column :experiments,:submission_id, :integer, :null => false
  end
end
