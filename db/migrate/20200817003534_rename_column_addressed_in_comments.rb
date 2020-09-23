class RenameColumnAddressedInComments < ActiveRecord::Migration[6.0]
  def change
    rename_column :comments, :addressed, :resolved
  end
end
