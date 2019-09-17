# frozen_string_literal: true

class Post < ApplicationRecord
  attr_accessor :postable_param

  belongs_to :postable, class_name: 'User'
  belongs_to :author, class_name: 'User'
  has_many :comments, foreign_key: :commentable_id, as: :commentable, dependent: :destroy
  has_many :likes, foreign_key: :likeable_id, as: :likeable, dependent: :destroy
  has_many_attached :pics, dependent: :purge

  scope :order_created, -> { order(created_at: :desc) }

  validates :content, presence: true
end
