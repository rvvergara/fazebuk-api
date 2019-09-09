# frozen_string_literal: true

class CreateLikes < ActiveRecord::Migration[5.2]
  def change
    create_table :likes, id: :uuid do |t|
      t.uuid :liker_id
      t.string :likeable_type
      t.uuid :likeable_id

      t.timestamps
    end
    add_index :likes, :liker_id
    add_index :likes, :likeable_id
    add_foreign_key :likes, :users, column: :liker_id
    add_index :likes, %i[liker_id likeable_id], unique: true
  end
end
