# frozen_string_literal: true

json.newsfeed_posts_for @current_user.username
json.newsfeed_posts @newsfeed_posts do |post|
  json.partial! 'v1/shared/post', post: post
end
json.page @page
json.shown_on_page @newsfeed_posts.count
json.total_posts @current_user.newsfeed_posts.count
