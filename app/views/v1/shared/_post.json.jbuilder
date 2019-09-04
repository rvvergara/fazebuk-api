# frozen_string_literal: true

json.id post.id
json.author post.author.username
json.author_url "/v1/users/#{post.author.username}"
json.posted_to post.postable.username
json.postable_url "/v1/users/#{post.postable.username}"
json.content post.content
json.created_at post.created_at
json.updated_at post.updated_at
