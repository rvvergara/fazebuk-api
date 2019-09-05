# frozen_string_literal: true

json.mutual_friends_with @user.username
json.mutual_friends @mutual_friends
json.partial! 'v1/shared/friends_stats',
page: @page,
friends_count: @mutual_friends.count,
total_friends_count: @mutual_friends_count
