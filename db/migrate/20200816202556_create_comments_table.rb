class CreateCommentsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :comments_tables do |t|
        t.text :comment
        t.integer :submission_id
        t.integer :user_id
        t.boolean :resolved, :default => false
        t.timestamps
    end
  end
end
