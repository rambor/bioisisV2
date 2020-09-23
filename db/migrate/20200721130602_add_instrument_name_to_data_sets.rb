class AddInstrumentNameToDataSets < ActiveRecord::Migration[6.0]
  def change
    add_column :data_sets, :instrument_name, :text
  end
end
