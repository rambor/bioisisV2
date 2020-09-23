class CreateSubmissions < ActiveRecord::Migration[6.0]
  def change
    create_table :submissions do |t|
      t.string   "email",                                :default => "",   :null => false
      t.string   "data_directory",                                         :null => false
      t.integer  "editing_count",                        :default => 0,    :null => false
      t.boolean  "status",                               :default => true, :null => false
      t.integer  "user_id"
      t.string   "bioisis_id",              :limit => 6
      t.timestamps
    end
  end
end
