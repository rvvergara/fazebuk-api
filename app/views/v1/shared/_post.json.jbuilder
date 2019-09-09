# frozen_string_literal: true

json.extract! post, :id, :content, :created_at, :updated_at
json.author post.author.username
json.author_url "/v1/users/#{post.author.username}"
json.posted_to post.postable.username
json.postable_url "/v1/users/#{post.postable.username}"
