# frozen_string_literal: true

class Friendship < ApplicationRecord
  belongs_to :active_friend, class_name: 'User'
  belongs_to :passive_friend, class_name: 'User'

  default_scope { order(created_at: :asc) }

  validates :combined_ids, uniqueness: true

  before_validation :concatenate_ids
  before_validation :prevent_self_invite

  def confirm
    update(confirmed: true)
  end

  private

  def concatenate_ids
    self.combined_ids = [active_friend_id, passive_friend_id].sort.join
  end

  def prevent_self_invite
    return unless active_friend == passive_friend

    errors.add(:active_friend, :self, message: 'You cannot send yourself a friend request')
  end
end
