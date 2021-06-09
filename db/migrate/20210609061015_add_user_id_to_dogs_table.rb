class AddUserIdToDogsTable < ActiveRecord::Migration[5.2]
  def change
    add_reference :dogs, :user, index: true
    add_foreign_key :dogs, :users
  end
end
