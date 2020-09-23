class CreateNewTableContributors < ActiveRecord::Migration[6.0]
  def change
    create_table :contributors do |t|
      t.string "last_name"
      t.string "given_names"
      t.belongs_to :experiment
      t.timestamps
    end
  end
end
