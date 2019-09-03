# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :postable, class_name: 'User'
  belongs_to :author, class_name: 'User'

  default_scope { order(updated_at: :desc) }

  validates :content, presence: true
end
