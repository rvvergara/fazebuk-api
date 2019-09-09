# frozen_string_literal: true

json.id post.id
json.content post.content
json.created_at convert_to_i(post.created_at)
json.updated_at convert_to_i(post.updated_at)
json.author do
  json.username post.author.username
  json.url "/v1/users/#{post.author.username}"
end
json.posted_to do
  json.username post.postable.username
  json.url json.postable_url "/v1/users/#{post.postable.username}"
end
json.comments do
  json.count post.comments.count
  json.list do
    json.array! post.comments do |comment|
      json.partial! '/v1/shared/comment', comment: comment
    end
  end
end
