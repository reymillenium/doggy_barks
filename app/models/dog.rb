class Dog < ApplicationRecord
  has_many_attached :images

  # Defines the amount of rows per page using the will_paginate gem:
  self.per_page = 5

  # Relations:
  # Assumption # 1: As the challenge doesn't gives much information => any User object is a potential owner, without any extra condition
  # Assumption # 2: The already existing Dog objects on the DB doesn't have any owner & a Dog object can exist without an owner (therefore the belongs_to relation is optional)
  belongs_to :user, optional: true, foreign_key: :user_id, class_name: User.class_name, inverse_of: :dogs
  has_many :likes
end
