# frozen_string_literal: true

class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments, id: :uuid do |t|
      t.text :body
      t.uuid :commentable_id
      t.uuid :commenter_id
      t.string :commentable_type

      t.timestamps
    end
    add_index :comments, :commentable_id
    add_index :comments, :commenter_id
    add_foreign_key :comments, :users, column: :commenter_id
  end
end
