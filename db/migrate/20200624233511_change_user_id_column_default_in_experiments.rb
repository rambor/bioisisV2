class ChangeUserIdColumnDefaultInExperiments < ActiveRecord::Migration[6.0]
  def change
    change_column :experiments, :user_id, :integer, :null => false
  end
end
