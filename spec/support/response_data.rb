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
  end
end
