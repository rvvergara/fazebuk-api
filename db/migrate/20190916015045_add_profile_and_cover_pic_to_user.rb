# frozen_string_literal: true

class AddProfileAndCoverPicToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :profile_pic, :string
    add_column :users, :cover_pic, :string
  end
end
