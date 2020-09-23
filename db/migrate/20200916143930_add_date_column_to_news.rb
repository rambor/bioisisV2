class AddDateColumnToNews < ActiveRecord::Migration[6.0]
  def change
    add_column :news, :publication_date, :date
  end
end
