# frozen_string_literal: true

json.friends_of @user.username
json.friends @friends do |friend|
  json.bio friend.bio
  json.birthday friend.birthday
  json.created_at friend.created_at
  json.email friend.email
  json.first_name friend.first_name
  json.gender friend.gender
  json.id friend.id
  json.last_name friend.last_name
  json.middle_name friend.middle_name
  json.updated_at friend.updated_at
  json.username friend.username
  json.is_already_a_friend? @current_user.friends.include?(friend)
  json.has_pending_sent_request_to? @current_user.pending_sent_requests_to.include?(friend)
  json.has_pending_received_request_from? @current_user.pending_received_requests_from.include?(friend)
end
