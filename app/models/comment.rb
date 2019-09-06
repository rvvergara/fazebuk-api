# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :author, class_name: 'User'
  belongs_to :commentable, polymorphic: true
  has_many :comments, as: :commentable, dependent: :destroy
end
