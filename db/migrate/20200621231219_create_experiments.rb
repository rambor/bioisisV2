class CreateExperiments < ActiveRecord::Migration[6.0]
  def change
    create_table :experiments do |t|
      t.text :description, :null => false
      t.text :title, :limit => 200, :null => false
      t.boolean :status, :default => false, :null => false
      t.text :publication
      t.text :publication_doi
      t.string :doi
      t.string :bioisis_id, :limit => 6

      t.timestamps
    end
  end
end
