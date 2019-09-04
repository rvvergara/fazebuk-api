# frozen_string_literal: true

json.timeline_posts_of @user.username
json.timeline_posts @timeline_posts do |post|
  json.partial! 'v1/shared/post', post: post
end
