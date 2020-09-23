class CreatePublications < ActiveRecord::Migration[6.0]
  def change
    create_table :publications do |t|
      t.string   "doi"
      t.string   "url"
      t.string "container-title"
      t.string 'title'
      t.string "volume"
      t.string "issue"
      t.string "page"
      t.integer "year"
      t.integer "month"
      t.belongs_to :experiment
      t.timestamps
    end
  end
end
