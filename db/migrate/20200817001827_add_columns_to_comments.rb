class AddColumnsToComments < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :comment, :text
    add_column :comments, :submission_id, :integer
    add_column :comments, :user_id, :integer
    add_column :comments, :addressed, :boolean, :default => false
    drop_table :comments_tables
  end
end
