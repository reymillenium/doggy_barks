class Dog < ApplicationRecord
  has_many_attached :images
  # Allows to query an ActiveRecord class for results from the database in an arbitrary order
  extend OrderAsSpecified

  # Defines the amount of rows per page using the will_paginate gem:
  self.per_page = 5

  # Relations:
  # Assumption # 1: As the challenge doesn't gives much information => any User object is a potential owner, without any extra condition
  # Assumption # 2: The already existing Dog objects on the DB doesn't have any owner & a Dog object can exist without an owner (therefore the belongs_to relation is optional)
  belongs_to :user, optional: true, foreign_key: :user_id, class_name: User.name, inverse_of: :dogs
  has_many :likes

  # Validations:
  validates :name, presence: true
  validates :birthday, timeliness: { on_or_before: lambda { Date.current }, type: :date }, allow_blank: true

  # Scopes:
  scope :owned_by, ->(user) {
    where(user_id: user)
  }

  scope :not_owned_by, ->(user) {
    where.not(id: owned_by(user).select(:id))
  }

  scope :free, -> {
    where(user_id: nil)
  }

  scope :owned_by_or_free, ->(user) {
    owned_by_ids = owned_by(user).select(:id)
    free_dogs_ids = free.select(:id)

    where("id IN (:owned_by) OR id IN (:free_dogs)",
          owned_by: owned_by_ids,
          free_dogs: free_dogs_ids)
  }

  scope :not_owned_by_nor_free, ->(user) {
    where.not(id: owned_by_or_free(user).select(:id))
  }

  # The exercise only allows their own dogs (so the free dogs are excluded)
  scope :editable_by, ->(user) {
    where(id: owned_by(user).select(:id))
  }

  # The exercise only excludes their own dogs (so the free dogs are still included)
  scope :likable_by, ->(user) {
    where(id: not_owned_by(user).select(:id))
  }

  scope :liked_by_user, ->(user) {
    where(id: Like.by_user(user).select(:dog_id))
  }

  scope :not_liked_by_user, ->(user) {
    where.not(id: liked_by_user(user).select(:id))
  }

  scope :ordered_by_likes, -> {
    # Gets all the liked dogs, ordered by the amount of likes on the last hour:
    liked_dogs_ordered_desc_ids = Dog.all.select { |dog| dog.last_hour_likes_amount > 0 }.sort_by(&:last_hour_likes_amount).reverse.pluck(:id)
    # Gets all the none liked dogs, ordered by id as default:
    none_liked_dogs_ids = Dog.all.select { |dog| dog.last_hour_likes_amount == 0 }.pluck(:id)
    # First the liked dogs (ordered desc) and then the none liked dogs (ordered by id as usual):
    desired_order_ids = liked_dogs_ordered_desc_ids + none_liked_dogs_ids
    Dog.order_as_specified(id: desired_order_ids)
  }

  # Instance Methods:
  def editable_by?(user)
    editable_by_ids = Dog.editable_by(user).pluck(:id)
    editable_by_ids.include?(self.id)
  end

  def destroyable_by?(user)
    destroyable_by_ids = Dog.editable_by(user).pluck(:id)
    destroyable_by_ids.include?(self.id)
  end

  def likable_by?(user)
    likable_by_user_ids = Dog.likable_by(user).pluck(:id)
    not_liked_yet_by_user_ids = Dog.likable_by(user).not_liked_by_user(user).pluck(:id)
    likable_by_user_ids.include?(self.id) && not_liked_yet_by_user_ids.include?(self.id)
  end

  def dislikeable_by?(user)
    likable_by_user_ids = Dog.likable_by(user).pluck(:id)
    liked_already_by_user_ids = Dog.likable_by(user).liked_by_user(user).pluck(:id)
    likable_by_user_ids.include?(self.id) && liked_already_by_user_ids.include?(self.id)
  end

  def has_no_likes?
    self.likes.empty?
  end

  def last_hour_likes_amount
    likes.where('created_at > ?', 1.hour.ago).count
  end
end
