# frozen_string_literal: true

class AddIndicesToFriendships < ActiveRecord::Migration[5.2]
  def change
    add_index :friendships, :active_friend_id
    add_index :friendships, :passive_friend_id
  end
end
