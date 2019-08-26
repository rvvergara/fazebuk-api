# frozen_string_literal: true

module Helpers
  module Authentication
    def login_as(user)
      post '/v1/sessions', params: {
        email_or_username: user.username,
        password: user.password
      }
    end

    def user_token
      JSON.parse(response.body)['user']['token']
    end
  end
end