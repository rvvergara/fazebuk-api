# frozen_string_literal: true

module Helpers
  module Authentication
    def login_as(user)
      post '/v1/sessions', params: {
        email: user.email,
        password: user.password
      }
    end

    def user_token
      JSON.parse(response.body)['user']['token']
    end

    def authorization_header
      { "Authorization": "Bearer #{user_token}" }
    end
  end
end
