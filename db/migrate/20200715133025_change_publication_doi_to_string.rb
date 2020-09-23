class ChangePublicationDoiToString < ActiveRecord::Migration[6.0]
  def change
    change_column :experiments, :publication_doi, :string
  end
end
