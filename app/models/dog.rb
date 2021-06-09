class Dog < ApplicationRecord
  has_many_attached :images

  # Defines the amount of rows per page using the will_paginate gem:
  self.per_page = 5
end
