# frozen_string_literal: true

json.timeline_posts_of user.username
json.timeline_posts timeline_posts do |post|
  json.partial! 'v1/shared/post', post: post
end
json.partial! '/v1/shared/posts_stats',
              page: page,
              page_posts_count: timeline_posts.count,
              total_posts_count: user.timeline_posts.count
