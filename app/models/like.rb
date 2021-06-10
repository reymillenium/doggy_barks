class Like < ApplicationRecord
  # Relations
  belongs_to :user
  belongs_to :dog

  # Scopes:
  scope :by_user, ->(users) {
    where(user_id: users)
  }

  scope :by_dog, ->(dogs) {
    where(dog_id: dogs)
  }
end
