# frozen_string_literal: true

class V1::FacebookAuthenticationsController < ApplicationController
  def create
    facebook_access_token = params.require(:access_token)
    begin
      user = User.find_or_create_with_facebook(facebook_access_token)
      if user
        render json: user.to_json, status: :ok
      else
        render json: user.to_json, status: :unprocessable_entity
      end
    rescue StandardError
      render json: { message: 'Access token has become invalid' }
    end
  end
end
