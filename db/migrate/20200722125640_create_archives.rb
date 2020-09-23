class CreateArchives < ActiveRecord::Migration[6.0]
  def change
    create_table :archives do |t|
      t.text "description"
      t.integer "experiment_id"
      t.timestamps
    end
  end
end
