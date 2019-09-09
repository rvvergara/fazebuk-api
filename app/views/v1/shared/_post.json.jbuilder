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
