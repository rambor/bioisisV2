class CreateTableMaterials < ActiveRecord::Migration[6.0]
  def change
    create_table :materials do |t|
      t.string   "material", :null => false
      t.timestamps
    end

  end
end
