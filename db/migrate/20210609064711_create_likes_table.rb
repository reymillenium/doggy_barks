class CreateLikesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :likes do |t|
      t.references :user, foreign_key: true
      t.references :dog, foreign_key: true
      t.timestamps
    end

    add_index :likes, [:user_id, :dog_id], unique: true
  end
end
