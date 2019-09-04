# frozen_string_literal: true

class CreateFriendships < ActiveRecord::Migration[5.2]
  def change
    create_table :friendships, id: :uuid do |t|
      t.uuid :active_friend_id, null: false
      t.uuid :passive_friend_id, null: false
      t.boolean :confirmed, null: false, default: false
      t.string :combined_ids

      t.timestamps
    end
    add_foreign_key :friendships, :users, column: :active_friend_id
    add_foreign_key :friendships, :users, column: :passive_friend_id
    add_index :friendships, :combined_ids, unique: true
  end
end
