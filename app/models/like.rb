class Like < ApplicationRecord
  # Relations
  belongs_to :user
  belongs_to :dog
end
