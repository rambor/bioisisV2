class ChangeBioisisIdLimit < ActiveRecord::Migration[6.0]
  def change
    change_column :experiments, :bioisis_id, :string, :limit => 10
    change_column :submissions, :bioisis_id, :string, :limit => 10
  end
end
