class AddReleaseDateToExperiment < ActiveRecord::Migration[6.0]
  def change
    add_column :experiments, :release_date, :date
  end
end
