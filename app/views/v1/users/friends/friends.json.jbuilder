# frozen_string_literal: true

json.friends_of user.username
json.displayed_friends displayed_friends do |friend|
  json.partial! 'v1/shared/user', user: friend
end
json.partial! 'v1/shared/friends_stats',
              page: page,
              displayed_friends_count: displayed_friends.count,
              total_friends_count: total_friends_count
