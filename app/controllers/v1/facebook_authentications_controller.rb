# frozen_string_literal: true

class V1::FacebookAuthenticationsController < ApplicationController
  def create
    facebook_access_token = params.require(:access_token)
    facebook_data = User.find_or_create_with_facebook(facebook_access_token)
    if facebook_data.class == User
      data = shown_attributes(facebook_data)
      token = JsonWebToken.encode(data)
      render :user, locals: { token: token, facebook_data: facebook_data }, status: :ok
    else
      render json: facebook_data, status: :unprocessable_entity
    end
  end
end
