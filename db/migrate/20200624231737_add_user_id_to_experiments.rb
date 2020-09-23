class AddUserIdToExperiments < ActiveRecord::Migration[6.0]
  def change
    add_column :experiments, :user_id, :integer, :default => false
  end
end
