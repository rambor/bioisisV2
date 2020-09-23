class ChangeColumnNameInPublications < ActiveRecord::Migration[6.0]
  def change
    rename_column :publications,"container-title", :container_title
  end
end
