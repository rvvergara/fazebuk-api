# frozen_string_literal: true

class Like < ApplicationRecord
  belongs_to :likeable, polymorphic: true
  belongs_to :liker, class_name: 'User'

  before_validation :prevent_duplicate

  private

  def prevent_duplicate
    return if Like.where('liker_id=? AND likeable_id=?', liker.id, likeable_id).empty?

    errors.add(:liker, "cannot like the #{likeable_type} twice")
  end
end
