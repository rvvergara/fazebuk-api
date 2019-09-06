# frozen_string_literal: true

class Post < ApplicationRecord
  attr_accessor :postable_param

  belongs_to :postable, class_name: 'User'
  belongs_to :author, class_name: 'User'
  has_many :comments, as: :commentable, dependent: :destroy

  scope :order_created, -> { order(created_at: :desc) }

  validates :content, presence: true
end
