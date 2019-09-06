# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :commenter, class_name: 'User'
  belongs_to :commentable, polymorphic: true
  has_many :replies, foreign_key: :commentable_id, class_name: 'Comment', as: :commentable, dependent: :destroy

  default_scope { order(updated_at: :asc) }

  validates :body, presence: true
end