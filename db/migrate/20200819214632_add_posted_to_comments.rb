class AddPostedToComments < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :posted, :boolean, :default => false
  end
end
