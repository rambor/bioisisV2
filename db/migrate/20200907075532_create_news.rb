class CreateNews < ActiveRecord::Migration[6.0]
  def change
    create_table :news do |t|
      t.integer  "user_id",      :null => false
      t.string   "title"
      t.text     "journal_info"
      t.text     "abstract"
      t.text     "notes"
      t.string   "category"
      t.string   "link"
      t.timestamps
    end
  end
end
