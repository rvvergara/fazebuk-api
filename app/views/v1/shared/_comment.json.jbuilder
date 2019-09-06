# frozen_string_literal: true

json.id comment.id
json.commenter comment.commenter.username
json.commenter_url "/v1/users/#{comment.commenter.username}"
json.body comment.body
json.created_at comment.created_at
json.updated_at comment.updated_at
