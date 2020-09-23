class AddBuffertoDataFiles < ActiveRecord::Migration[6.0]
  def change
    add_column :data_files, :buffer, :text, :default => "none"
    add_column :data_files, :description, :text
  end
end
