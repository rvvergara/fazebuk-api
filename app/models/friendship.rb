# frozen_string_literal: true

class Friendship < ApplicationRecord
  belongs_to :active_friend, class_name: 'User'
  belongs_to :passive_friend, class_name: 'User'

  validates :confirmed, presence: true, on: :update
  validates :combined_ids, presence: true, uniqueness: true

  before_validation :concatenate_ids

  def confirm
    update(confirmed: true)
  end

  private

  def concatenate_ids
    self.combined_ids = [active_friend_id, passive_friend_id].sort.join
  end
end
