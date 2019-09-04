# frozen_string_literal: true

json.newsfeed_posts_for @current_user.username
json.newsfeed_posts @newsfeed_posts do |post|
  json.partial! 'v1/shared/post', post: post
end
json.partial! '/v1/shared/posts_stats',
              page: @page,
              page_posts_count: @newsfeed_posts.count,
              total_posts_count: @current_user.newsfeed_posts.count
