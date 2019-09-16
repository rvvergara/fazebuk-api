# frozen_string_literal: true

json.bio user.bio
json.birthday user.birthday
json.cover_pic user.cover_pic
json.created_at user.created_at
json.email user.email
json.first_name user.first_name
json.gender user.gender
json.id user.id
json.last_name user.last_name
json.middle_name user.middle_name
json.profile_pic user.profile_pic
json.updated_at user.updated_at
json.username user.username
json.is_already_a_friend? pundit_user.friends.include?(user)
json.friendship_id pundit_user.friendship_id_with(user)
json.has_pending_sent_request_to? pundit_user.pending_sent_requests_to.include?(user)
json.has_pending_received_request_from? pundit_user.pending_received_requests_from.include?(user)
