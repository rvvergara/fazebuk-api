# frozen_string_literal: true

module Helpers
  module ResponseData
    def json_response
      JSON.parse(response.body)
    end

    def user_response_keys
      %w[
        bio birthday created_at email first_name gender id last_name middle_name
        updated_at username is_already_a_friend? friendship_id has_pending_sent_request_to?
        has_pending_received_request_from?
      ]
    end

    def friends_response_keys
      %w[
        friends_of displayed_friends page total_shown_on_page total
      ]
    end

    def mutual_friends_response_keys
      %w[
        mutual_friends_with displayed_mutual_friends page total_shown_on_page total
      ]
    end

    def timeline_posts_response_keys
      %w[
        timeline_posts_of timeline_posts page total_shown_on_page total_posts
      ]
    end

    def newsfeed_posts_response_keys
      %w[
        newsfeed_posts_for newsfeed_posts page total_shown_on_page total_posts
      ]
    end
  end
end
