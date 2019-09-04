# frozen_string_literal: true

json.bio user.bio
json.birthday user.birthday
json.created_at user.created_at
json.email user.email
json.first_name user.first_name
json.gender user.gender
json.id user.id
json.last_name user.last_name
json.middle_name user.middle_name
json.updated_at user.updated_at
json.username user.username
json.is_already_a_friend? @current_user.friends.include?(user)
json.has_pending_sent_request_to? @current_user.pending_sent_requests_to.include?(user)
json.has_pending_received_request_from? @current_user.pending_received_requests_from.include?(user)
