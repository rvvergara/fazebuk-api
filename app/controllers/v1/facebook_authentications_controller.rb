# frozen_string_literal: true

class V1::FacebookAuthenticationsController < ApplicationController
  def create
    facebook_access_token = params.require(:access_token)
    user = User.find_or_create_with_facebook(facebook_access_token)
    if user.class == User
      render json: user.to_json, status: :ok
    else
      error_message = user.split(',')[3].split(':')
      error_json = { error_message[0].to_sym => error_message[1] }
      render json: error_json, status: :unprocessable_entity
    end
  end
end
