# frozen_string_literal: true

json.id post.id
json.content post.content
json.created_at convert_to_i(post.created_at)
json.updated_at convert_to_i(post.updated_at)
json.author do
  json.partial! '/v1/shared/user_short', user: post.author
end
json.posted_to do
  json.partial! '/v1/shared/user_short', user: post.postable
end
json.comments do
  json.count post.comments.count
  json.list do
    json.array! post.comments do |comment|
      json.partial! '/v1/shared/comment', comment: comment
    end
  end
end
json.likes do
  json.count post.likes.count
  json.likers do
    json.array! post.likes do |like|
      json.partial! '/v1/shared/user_short', user: like.liker
    end
  end
end
json.liked? pundit_user.liked?(post)
json.like_id post.like_id(pundit_user)
json.pics do
  json.array! post.pics do |pic|
    json.partial! '/v1/shared/pic', pic: pic
  end
end
