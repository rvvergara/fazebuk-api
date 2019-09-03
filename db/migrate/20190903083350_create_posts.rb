class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts, id: :uuid do |t|
      t.uuid :author_id
      t.uuid :postable_id
      t.text :content

      t.timestamps
    end
    add_foreign_key :posts, :users, column: :author_id
    add_foreign_key :posts, :users, column: :postable_id
  end
end
