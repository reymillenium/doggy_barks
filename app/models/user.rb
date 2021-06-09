class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Relations
  # Assumption: A Dog object can exist without an owner (User object). Therefore there is not a destroy dependent relationship
  has_many :dogs, inverse_of: :user, foreign_key: :user_id, inverse_of: :user
  has_many :likes
end
