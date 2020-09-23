class ChangeApprovedColumnDefaultInExperiments < ActiveRecord::Migration[6.0]
  def change
    change_column_default :experiments, :approved, false
  end
end
