# frozen_string_literal: true

json.is_already_a_friend? pundit_user.friends.include?(user)
json.friendship_id pundit_user.friendship_id_with(user)
json.has_pending_sent_request_to? pundit_user.pending_sent_requests_to.include?(user)
json.has_pending_received_request_from? pundit_user.pending_received_requests_from.include?(user)
