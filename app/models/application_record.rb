# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def like_id(user)
    return unless user.liked?(self)

    user.likes.where('likeable_id=?', id).first.id
  end
end
