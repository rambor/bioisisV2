class CreateScatters < ActiveRecord::Migration[6.0]
  def change
    create_table :scatters do |t|
      t.text :comments, :null => false
      t.string :title, :null => false
      t.string :version, :null => false
      t.integer :count, :default => false
      t.timestamps
    end

    create_table :scatter_downloads do |t|
      t.string   :institution
      t.string   :country
      t.string   :ip_address
      t.string   :status
      t.string   :version
      t.belongs_to  :user
      t.string   :principal_investigator
      t.boolean  :email
      t.belongs_to :scatter
      t.timestamps
    end
  end
end
