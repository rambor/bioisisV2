class AddSourceToDataSets < ActiveRecord::Migration[6.0]
  def change
    add_column :data_sets, :source, :text
  end
end
