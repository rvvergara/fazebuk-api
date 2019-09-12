# frozen_string_literal: true

json.mutual_friends_with user.username
json.displayed_mutual_friends displayed_mutual_friends
json.partial! 'v1/shared/friends_stats',
              page: page,
              displayed_friends_count: displayed_mutual_friends.count,
              total_friends_count: total_mutual_friends_count
