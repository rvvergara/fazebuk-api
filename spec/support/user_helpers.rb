# frozen_string_literal: true

module Helpers
  module UserHelpers
    def update_user(username, attributes)
      put user_route(username),
          headers: authorization_header,
          params: user_params(attributes)
    end

    def user_params(attributes_hash)
      { user: attributes_hash }
    end

    def valid_user_attributes
      attributes_for(:user, :male)
    end

    def invalid_user_attributes
      attributes_for(:user, :male, :invalid, first_name: nil)
    end
  end
end
