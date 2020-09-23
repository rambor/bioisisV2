class AddApprovedToExperiments < ActiveRecord::Migration[6.0]
  def change
    add_column :experiments, :approved, :boolean
  end
end
