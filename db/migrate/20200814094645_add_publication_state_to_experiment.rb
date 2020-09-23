class AddPublicationStateToExperiment < ActiveRecord::Migration[6.0]
  def change
    add_column :experiments, :state, :string
  end
end
